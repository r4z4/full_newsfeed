defmodule FullNewsfeedWeb.HomeLive do
  use FullNewsfeedWeb, :live_view
  require Logger

  alias FullNewsfeed.Account
  # alias FullNewsfeed.Core.TopicHelpers
  # alias FullNewsfeedWeb.Components.StateSnapshot
  alias FullNewsfeedWeb.Components.PresenceDisplay
  alias FullNewsfeed.Core.{Utils, Hold}

  def mount(_params, session, socket) do
    # Send to ETS table vs storing in socket
    # g_candidates = api_query(socket.assigns.current_user.state)
    task =
      Task.Supervisor.async(FullNewsfeed.TaskSupervisor, fn ->
        IO.puts("Hey from a task")
        api_query(socket.assigns.current_user.state)
      end)
    Logger.info("Home Socket = #{inspect socket}", ansi_color: :magenta)

    floor_task =
      Task.Supervisor.async(FullNewsfeed.TaskSupervisor, fn ->
        IO.puts("Hey from a task")
        floor_actions = floor_query("house")
      end)

    {:ok,
     socket
     |> assign(:messages, [])
     |> assign(:floor_actions, Task.await(floor_task, 10000))
     |> assign(:social_count, 0)}
  end


  # defp get_favorites(holds) do
  #   # IO.inspect(holds, label: "holds")
  #   all_holds = holds.candidate_holds ++ holds.user_holds ++ holds.election_holds ++ holds.race_holds ++ holds.post_holds ++ holds.thread_holds
  #   |> Enum.filter(fn x -> x.type == :favorite end)
  # end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header class="text-center">
        Hello <%= assigns.current_user.username %> || Welcome to Fantasy Candidate
        <:subtitle>Not Really Sure What We're Doing Here Yet</:subtitle>
      </.header>

      <div class="grid justify-center mx-auto text-center md:grid-cols-3 lg:grid-cols-3 gap-10 lg:gap-10 my-10 text-white">

        <div>
          <.link
            href={~p"/candidates/main"}
            class="group -mx-2 -my-0.5 inline-flex items-center gap-3 rounded-lg px-2 py-0.5 hover:bg-zinc-50 hover:text-zinc-900"
          >
            <Heroicons.LiveView.icon name="users" type="outline" class="h-10 w-10 text-emerald" />
            Candidates
          </.link>
        </div>

        <div>
          <.link
            href={~p"/forums/main"}
            class="group -mx-2 -my-0.5 inline-flex items-center gap-3 rounded-lg px-2 py-0.5 hover:bg-zinc-50 hover:text-zinc-900"
          >
            <Heroicons.LiveView.icon name="chat-bubble-left-right" type="outline" class="h-10 w-10 text-white" />
            Forums
          </.link>
        </div>

      </div>

      <div class="relative flex py-5 items-center">
        <div class="flex-grow border-t border-gray-400"></div>
        <span class="flex-shrink mx-4 text-gray-400">Content</span>
        <div class="flex-grow border-t border-gray-400"></div>
      </div>

    </div>
    """
  end

  @impl true
  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("send_message", %{"message" => %{"text" => text, "subject" => subject, "to" => to, "patch" => patch}}, socket) do
    Logger.info("Params are #{text} and #{subject} and to is #{to}", ansi_color: :blue_background)
    case attrs = %{id: UUIDv7.generate(), to: to, from: socket.assigns.current_user.id, subject: subject, type: :p2p, text: text} |> FullNewsfeed.Site.create_message() do
      {:ok, _} ->
        notif = "Your message has been sent!"
        recv = %{type: :p2p, string: "New Message Received"}
        FullNewsfeedWeb.Endpoint.broadcast!("user_" <> to, "new_message", recv)
        {:noreply,
          socket
          |> put_flash(:info, notif)
          |> push_navigate(to: patch)}
      {:error, changeset} ->
        Logger.info("Send Message Erroer", ansi_color: :yellow)
        notif = "Error Sending Message."
        {:noreply,
          socket
          |> put_flash(:error, notif)}
    end
  end

  # def get_loc_info(ip) do
  #   {:ok, resp} =
  #   #   Finch.build(:get, "https://ip.city/api.php?ip=#{ip}&key=#{System.fetch_env!("IP_CITY_API_KEY")}")
  #   #   |> Finch.request(FullNewsfeed.Finch)
  #       Finch.build(:get, "https://ipinfo.io/#{ip}?token=#{System.fetch_env!("IP_INFO_TOKEN")}")
  #       |> Finch.request(FullNewsfeed.Finch)
  #   IO.inspect(resp, label: "Loc Info Resp")
  #   resp
  # end

  @impl true
  def handle_info(
      %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
      %{assigns: %{social_count: count}} = socket
    ) do
    IO.inspect(count, label: "Count")
    social_count = count + map_size(joins) - map_size(leaves)

    {:noreply, assign(socket, :social_count, social_count)}
  end

  def get_str(state) do
    Enum.zip(Utils.states, Utils.state_names ++ Utils.territories)
      |> Enum.find(fn {abbr,name} -> abbr == state end)
      |> Kernel.elem(1)
      |> Atom.to_string()
  end

  def api_query(state) do
    state_str = get_str(state)
    {:ok, resp} =
      Finch.build(:get, "https://civicinfo.googleapis.com/civicinfo/v2/representatives?address=#{state_str}&key=#{System.fetch_env!("GCLOUD_PROJECT")}")
      |> Finch.request(FullNewsfeed.Finch)

    {:ok, body} = Jason.decode(resp.body)

    # IO.inspect(body["offices"], label: "Offices")

    %{"offices" => body["offices"], "officials" => body["officials"]}
  end

      @doc """
      "results" => [
        %{
          "chamber" => "House",
          "congress" => "118",
          "date" => "2023-07-30",
          "floor_actions" => [],
          "num_results" => 0,
          "offset" => 0
        }
      ],
    """

  defp floor_query(chamber \\ "house") do
    date = Date.utc_today()
    # state_str = get_str(state)
    # IO.inspect(state_str, label: "State")
    {:ok, resp} =
      Finch.build(:get, "https://api.propublica.org/congress/v1/#{chamber}/floor_updates/#{date.year}/#{date.month}/#{date.day}.json", [{"X-API-Key", System.fetch_env!("PROPUB_KEY")}])
      |> Finch.request(FullNewsfeed.Finch)

    {:ok, body} = Jason.decode(resp.body)

    body["results"]
  end

  @impl true
  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  @impl true
  def handle_info(%{event: "new_message", payload: new_message}, socket) do
    case new_message.type do
      :p2p -> Logger.info("In this case we need to refetch all unread messages from DB and display that number", ansi_color: :magenta_background)
      :candidate -> Logger.info("Cndidate New Message", ansi_color: :yellow)
      :post -> Logger.info("Post New Message", ansi_color: :yellow)
      :thread -> Logger.info("Thread New Message", ansi_color: :yellow)
    end

    {:noreply,
     socket
     |> assign(:messages, FullNewsfeed.Site.list_user_messages(socket.assigns.current_user.id))
     |> put_flash(:info, "PubSub: #{new_message.string}")}
  end

  # def handle_event("new_message", params, socket) do
  #   {:noreply, socket}
  # end
end
