defmodule FullNewsfeedWeb.ChatLive do
  use FullNewsfeedWeb, :live_view
  alias FullNewsfeed.Entities.{Embedding, FinalData}
  alias FullNewsfeed.Repo
  import Ecto.Query
  import Pgvector.Ecto.Query
  require Logger

  def get_similars(user_id) do
    query = Ecto.Query.from(e in Embedding, where: e.user_id == ^user_id, order_by: [desc: e.inserted_at], limit: 1)
    most_recent = Repo.one(query)
    if most_recent do
      emb = most_recent.embedding
      Repo.all(from e in Embedding, order_by: l2_distance(e.embedding, ^emb), limit: 5)
    else
      nil
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    Logger.info("This Process ->> #{inspect(self())}. Chat Live Socket = #{inspect socket}", ansi_color: :magenta)

    {:ok,
     socket
     |> assign(:messages, [])
     |> assign(:alert, nil)
     |> assign(:bank_data, nil)
     |> assign(:headlines_data, nil)
     |> assign(:current_request, nil)
     |> assign(:prompt, nil)
     |> assign(:embedding, [])
     |> assign(:display, "")
     |> assign(:final_data, nil)
     |> assign(:response, nil)
     |> assign(:similars, get_similars(socket.assigns.current_user.id))
     |> assign(:beer_data, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full">
      <.header class="text-center">
        Hello <%= assigns.current_user.username %> || Welcome to Chat Live
      </.header>

      <form phx-submit="prompt" class="m-0 flex space-x-2">
        <input
          class="block w-full p-2.5 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500"
          type="text"
          name="message"
          value={@prompt}
        />
        <button
          class="px-5 py-2.5 text-center mr-2 inline-flex items-center text-white bg-blue-700 font-medium rounded-lg text-sm hover:bg-blue-800 focus:ring-4 focus:ring-blue-300"
          type="submit"
          disabled={false}
        >
          Predict
        </button>
      </form>
      <Phoenix.Component.async_result :let={response} assign={@response} :if={@response}>
        <:loading>
          <.spinner />
        </:loading>
        <:failed :let={_reason}>
          <span>Oops, something went wrong!</span>
        </:failed>
        <span class="text-gray-900 font-medium"><%= response %></span>
      </Phoenix.Component.async_result>

      <div class="grid justify-center mx-auto w-full text-center md:grid-cols-3 lg:grid-cols-3 gap-2 lg:gap-2 my-10 text-white">
        <h3>Embeddings</h3>
        <p><%= assigns.embedding %></p>
      </div>

      <div class="grid justify-center mx-auto w-full text-center md:grid-cols-3 lg:grid-cols-3 gap-2 lg:gap-2 my-10 text-white">
        <p><%= assigns.display %></p>
      </div>

      <div :if={assigns.final_data} class="grid justify-center mx-auto w-full text-center md:grid-cols-3 lg:grid-cols-3 gap-2 lg:gap-2 my-10 text-white" id="final_data_display">
        <p>Model: <%= assigns.final_data.model %></p>
        <p>Eval: <%= assigns.final_data.prompt_eval_duration %></p>
        <p>Total: <%= assigns.final_data.total_duration %></p>
      </div>

      <.markdown text={@display} />


    </div>
    """
  end

  defp spinner(assigns) do
    ~H"""
    <svg
      class="inline mr-2 w-4 h-4 text-gray-200 animate-spin fill-blue-600"
      viewBox="0 0 100 101"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
        fill="currentColor"
      />
      <path
        d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
        fill="currentFill"
      />
    </svg>
    """
  end

  def markdown(assigns) do
    text = if assigns.text == nil, do: "", else: assigns.text

    markdown_html =
      String.trim(text)
      |> Earmark.as_html!(code_class_prefix: "lang- language-")
      |> Phoenix.HTML.raw()

    assigns = assign(assigns, :markdown, markdown_html)

    ~H"""
    <%= @markdown %>
    """
  end
  # When the client invokes the "prompt" event, create a streaming request and
  # asynchronously send messages back to self.
  @impl true
  def handle_event("prompt", %{"message" => prompt}, socket) do
    ollama_client = Ollama.init()
    {:ok, embedding} = Ollama.embeddings(ollama_client, [
      model: "codellama",
      prompt: prompt,
    ])

    {:ok, task} = Ollama.completion(ollama_client, [
      model: "codellama",
      prompt: prompt,
      stream: self(),
    ])

    {:ok, json_embedding} = Jason.encode(embedding["embedding"])
    Task.async(fn -> Repo.insert(%Embedding{user_id: socket.assigns.current_user.id, embedding: embedding["embedding"]}, prompt: prompt) end)

    {:noreply,
      socket
      |> assign(current_request: task)
      |> assign(embedding: json_embedding)
      |> assign(final_data: nil)
      |> assign(display: "")
    }
  end

  @impl true
  def handle_info({_pid, {:ok, _embedding = %Embedding{}}}, socket) do
    IO.puts("DB Operation has completed")
    {:noreply, socket}
  end

  @impl true
  def handle_info({:DOWN, _reference, _process, _pid, _status}, socket) do
    IO.puts("Down Received. Task Destroyed.")
    {:noreply, socket}
  end

  # The streaming request sends messages back to the LiveView process.
  @impl true
  def handle_info({_request_pid, {:data, _data}} = message, socket) do
    pid = socket.assigns.current_request.pid
    case message do
      {^pid, {:data, %{"done" => false} = data}} ->
        display = socket.assigns.display <> to_string(data["response"])
        IO.inspect(data, label: "Streaming Data")
        IO.puts("handle each streaming chunk")
        {:noreply,
          socket
            |> assign_async(:response, fn ->
              {:ok, %{response: to_string(data["response"])}}
            end)
            |> assign(display: display)
        }

      {^pid, {:data, %{"done" => true} = data}} ->
        display = socket.assigns.display <> to_string(data["response"])
        IO.inspect(data, label: "Final Data")
        IO.puts("handle the final streaming chunk")
        {:noreply,
          socket
            |> assign_async(:response, fn ->
              {:ok, %{response: to_string(data["response"])}}
            end)
            |> assign(display: display)
            |> assign(final_data: %FinalData{total_duration: data["total_duration"], prompt_eval_duration: data["prompt_eval_duration"], model: data["model"], eval_duration: data["eval_duration"]})
        }

      {_pid, _data} ->
        IO.puts("this message was not expected!")
        {:noreply, socket}
    end
  end

  # Tidy up when the request is finished
  @impl true
  def handle_info({ref, {:ok, %Req.Response{status: 200}}}, socket) do
    Process.demonitor(ref, [:flush])
    {:noreply, assign(socket, current_request: nil)}
  end
end
