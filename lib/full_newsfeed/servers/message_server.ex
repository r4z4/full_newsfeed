defmodule FullNewsfeed.Servers.MessageServer do
  use GenServer
  import Ecto.Query, only: [from: 2]
  alias Ecto.UUID
  alias FullNewsfeed.Repo
  alias FullNewsfeed.Messages.Notification
  alias FullNewsfeed.Core.Hold

  @time_interval_ms 2000
  @call_interval_ms 3000
  @addrs "addrs"

  def to_notification(%{"about_entity" => about_entity, "about_id" => about_id, "to" => to, "subject" => subject, "message" => message, "sent_at" => sent_at}) do

    %Notification{
      about_entity: about_entity,
      about_id: about_id,
      to: to,
      subject: subject,
      message: message,
      sent_at: sent_at
    }
  end

  def scan_and_send_notification(%{:entity => entity, :id => id}) do
    IO.inspect(entity, label: "Entity")
    query = from h in Hold, select: h.user_id, where: h.hold_cat == ^entity, where: h.hold_cat_id == ^id
    hold_ids = Repo.all(query)
    for id <- hold_ids do
      IO.puts("Sending a message to user #{id}")
    end
    # Also send out PubSub
    # FullNewsfeedWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
  end

  def start_link([name, state]) do
    IO.inspect(state, label: "Start Link for Message Server")
    GenServer.start_link(__MODULE__, state, name: name)
  end

  @impl true
  def handle_cast({:scan_and_send_notification, %{:entity => entity_atom, :id => entity_id}}, state) do
    scan_and_send_notification(%{:entity => entity_atom, :id => entity_id})
    # Process.send_after(self(), sym, @time_interval_ms)
    IO.puts("Scan and Send Notification Sent?")
    {:noreply, state}
  end

  # handle_cast handling the call from outside. Calls from the process (all subsequent) handled by handle_info
  @impl true
  def handle_cast({:fetch_resource, sym}, state) do
    Process.send_after(self(), sym, @time_interval_ms)
    IO.puts(sym)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:stop_resource, sym}, state) do
    case sym do
      :streamer -> Process.cancel_timer(state.streamer_ref)
      _ -> Process.cancel_timer(state.streamer_ref)
    end
    # Process.cancel_timer(self(), sym, @time_interval_ms)
    IO.puts(sym)
    {:noreply, state}
  end

  @impl true
  def init(state) do
    # _table = :ets.new(:user_scores, [:ordered_set, :protected, :named_table])
    IO.inspect state, label: "init"
    refs_map = %{addrs_ref: nil}
    {:ok, refs_map}
  end

  defp publish(list) do
    Phoenix.PubSub.broadcast(
      DoiEsper.PubSub,
      @addrs,
      %{topic: @addrs, payload: %{status: :complete, data: list}}
    )
  end

  # @impl true
  # def handle_info(:addrs, state) do
  #   IO.inspect(state.addrs_ref, label: "Addr Ref Calling get_addrs()")
  #   {_atom, body} = get_addrs()
  #   # Body will always be a list of maps
  #   IO.inspect(body, label: "Body")
  #   round_id = Ecto.UUID.generate()
  #   addrs = Enum.map(body, fn addr -> to_addr(addr, round_id) end)
  #   IO.inspect(addrs, label: "addrs")
  #   # Need to be maps to do insert all. ugh.
  #   maps = Enum.map(addrs, fn addr -> Map.from_struct(addr) |> Map.delete(:__meta__) end)
  #   IO.inspect(maps, label: "maps")
  #   DoiEsper.Repo.insert_all(Address, maps)
  #   publish(body)
  #   addrs_ref = Process.send_after(self(), :addrs, @call_interval_ms)
  #   IO.inspect(addrs_ref, label: "New Addrs Ref")
  #   state = Map.put(state, :addrs_ref, addrs_ref)
  #   {:noreply, state}
  # end


end
