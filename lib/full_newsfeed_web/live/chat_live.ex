defmodule FullNewsfeedWeb.ChatLive do
  use FullNewsfeedWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    Logger.info("Chat Live Socket = #{inspect socket}", ansi_color: :magenta)

    {:ok,
     socket
     |> assign(:messages, [])
     |> assign(:alert, nil)
     |> assign(:bank_data, nil)
     |> assign(:headlines_data, nil)
     |> assign(:prompt, nil)
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

      <div class="grid justify-center mx-auto w-full text-center md:grid-cols-3 lg:grid-cols-3 gap-2 lg:gap-2 my-10 text-white">

      </div>


    </div>
    """
  end
  # When the client invokes the "prompt" event, create a streaming request and
  # asynchronously send messages back to self.
  def handle_event("prompt", %{"message" => prompt}, socket) do
    {:ok, task} = Ollama.completion(Ollama.init(), [
      model: "codellama",
      prompt: prompt,
      stream: self(),
    ])

    {:noreply, assign(socket, current_request: task)}
  end

  # The streaming request sends messages back to the LiveView process.
  def handle_info({_request_pid, {:data, _data}} = message, socket) do
    pid = socket.assigns.current_request.pid
    case message do
      {^pid, {:data, %{"done" => false} = data}} ->
        IO.inspect(data, label: "Data")
        IO.puts("handle each streaming chunk")
        {:noreply, socket}

      {^pid, {:data, %{"done" => true} = data}} ->
        IO.puts("handle the final streaming chunk")
        {:noreply, socket}

      {_pid, _data} ->
        IO.puts("this message was not expected!")
        {:noreply, socket}
    end
  end

  # Tidy up when the request is finished
  def handle_info({ref, {:ok, %Req.Response{status: 200}}}, socket) do
    Process.demonitor(ref, [:flush])
    {:noreply, assign(socket, current_request: nil)}
  end
end
