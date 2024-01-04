defmodule FullNewsfeedWeb.HomeLive do
  use FullNewsfeedWeb, :live_view
  require Logger

  alias FullNewsfeed.Account
  # alias FullNewsfeed.Core.TopicHelpers
  # alias FullNewsfeedWeb.Components.StateSnapshot
  # alias FullNewsfeedWeb.Components.PresenceDisplay
  alias Ecto.UUID
  alias FullNewsfeed.Repo
  alias FullNewsfeed.Items.Beer
  alias FullNewsfeed.Core.{Utils, Hold}

  def mount(_params, _session, socket) do
    # Send to ETS table vs storing in socket
    # g_candidates = api_query(socket.assigns.current_user.state)
    _task =
      Task.Supervisor.async(FullNewsfeed.TaskSupervisor, fn ->
        IO.puts("Hey from a task")
        %{resp: "Test Response"}
      end)
    Logger.info("Home Socket = #{inspect socket}", ansi_color: :magenta)

    floor_task =
      Task.Supervisor.async(FullNewsfeed.TaskSupervisor, fn ->
        IO.puts("Hey from a task")
        %{resp: "Test Response"}
      end)

    {:ok,
     socket
     |> assign(:messages, [])
     |> assign(:alert, nil)
     |> assign(:floor_actions, Task.await(floor_task, 10000))
     |> assign(:bank_data, nil)
     |> assign(:cc_data, nil)
     |> assign(:beer_data, nil)}
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
        Hello <%= assigns.current_user.username %> || Welcome to Full Newsfeed
      </.header>

      <div class="grid justify-center mx-auto text-center md:grid-cols-3 lg:grid-cols-3 gap-10 lg:gap-10 my-10 text-white">

        <div class="basis-1/3 flex flex-col items-center justify-center">
          <button
            type="button"
            phx-click="service_casted"
            phx-value-entity={:bank}
            value={:val_test}
            class="inline-block rounded border-2 border-success w-3/3 px-2 pb-[6px] pt-2 text-xs font-medium uppercase leading-normal text-success transition duration-150 ease-in-out hover:border-success-600 hover:bg-neutral-500 hover:bg-opacity-10 hover:text-success-600 focus:border-success-600 focus:text-success-600 focus:outline-none focus:ring-0 active:border-success-700 active:text-success-700 dark:hover:bg-neutral-100 dark:hover:bg-opacity-10"
          >
          <svg height="40px" width="40px" version="1.1" id="_x34_" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512" xml:space="preserve" fill="#000000"><g id="SVGRepo_bgCarrier" stroke-width="0"></g><g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g><g id="SVGRepo_iconCarrier"> <g> <g> <g> <g> <rect x="56.393" y="53.526" transform="matrix(0.9704 -0.2416 0.2416 0.9704 -32.9774 70.4523)" style="fill:#78A271;" width="428.744" height="232.315"></rect> <path style="fill:#48793E;" d="M497.291,174.76L468.517,59.003L456.016,8.797L453.832,0l-5.292,1.323L394.83,14.684 L88.504,91.018l-59.003,14.684l9.723,38.96l0.992,4.167l1.058,4.101l2.91,11.708l6.548,26.392l22.291,89.364l12.832,51.595 l1.852,7.341l7.276-1.786l51.661-12.898l279.536-69.587l26.856-6.681l11.444-2.844l4.167-1.059l4.102-0.992l39.225-9.789 L497.291,174.76z M432.6,244.677l-160.34,39.952l-27.65,6.88l-100.014,24.938L93.928,329.08l-12.634-50.735l-24.408-97.897 l-4.432-17.859l-2.91-11.708l-1.058-4.1l-0.992-4.168l-7.673-30.758L90.555,99.22l306.392-76.267l50.668-12.634l12.634,50.735 l28.84,115.757l12.634,50.669l-31.022,7.739l-4.167,0.992l-4.101,1.059l-11.444,2.844L432.6,244.677z"></path> </g> <g> <g> <path style="fill:#48793E;" d="M288.449,240.704c-39.161,9.751-78.953-14.175-88.705-53.336 c-9.751-39.161,14.175-78.953,53.336-88.705c39.161-9.751,78.953,14.175,88.705,53.336 C351.536,191.16,327.61,230.953,288.449,240.704z"></path> </g> </g> <g> <path style="fill:#78A271;" d="M297.958,169.475c-1.542-2.386-3.532-4.224-5.965-5.514c-1.977-1.188-4.174-1.952-6.593-2.298 c-2.419-0.346-5.373-0.343-8.861,0.015l-0.674,0.063l-8.418,0.779c-1.627,0.19-3.035,0.171-4.222-0.044 c-0.495-0.086-0.968-0.202-1.421-0.342c-0.627-0.195-1.205-0.439-1.745-0.729c-0.947-0.564-1.679-1.256-2.215-2.071 c-0.529-0.816-0.917-1.704-1.157-2.667c-0.634-2.545-0.266-4.951,1.101-7.224c0.187-0.311,0.396-0.61,0.634-0.89 c1.47-1.813,3.868-3.13,7.19-3.957c1.803-0.449,3.721-0.754,5.757-0.91c0.682-0.053,1.375-0.09,2.083-0.113 c2.824-0.081,5.645,0.694,8.459,2.326l6.832-11.224c-3.928-2.303-7.942-3.636-12.046-4c-2.631-0.231-5.469-0.134-8.499,0.306 c-0.491-1.725-1.62-3.118-3.066-3.983c-1.507-0.911-3.363-1.243-5.194-0.787c-3.663,0.912-5.92,4.657-5.006,8.326l0.1,0.4 c-0.845,0.438-1.652,0.904-2.419,1.409c-2.886,1.882-5.183,4.079-6.894,6.58c-1.709,2.506-2.814,5.262-3.304,8.265 c-0.495,3.004-0.326,6.157,0.496,9.455c1.556,6.249,4.504,10.624,8.842,13.114c2.046,1.171,4.32,1.971,6.835,2.404 c1.986,0.337,4.24,0.44,6.783,0.293c0.687-0.036,1.388-0.087,2.116-0.158l9.092-0.842c1.022-0.101,1.907-0.155,2.66-0.17 c0.669-0.007,1.234,0.013,1.692,0.071c0.978,0.12,1.929,0.431,2.859,0.926c1.884,1.137,3.148,2.977,3.78,5.516 c0.736,2.956,0.199,5.497-1.605,7.62c-0.693,0.825-1.579,1.569-2.652,2.23c-1.706,1.059-3.887,1.916-6.548,2.579 c-2.261,0.563-4.502,0.906-6.713,1.025c-1.075,0.058-2.138,0.065-3.202,0.022c-3.242-0.141-6.322-1.085-9.239-2.84 l-6.966,11.578c4.478,2.757,9.071,4.291,13.786,4.613c2.806,0.194,5.763,0.079,8.872-0.338c0.966,3.582,4.668,5.769,8.285,4.868 c3.669-0.914,5.918-4.662,5.006-8.326l-0.023-0.093c1.275-0.564,2.497-1.194,3.667-1.886c3.086-1.821,5.608-3.982,7.577-6.479 c1.97-2.497,3.299-5.291,3.989-8.38c0.69-3.089,0.587-6.419-0.302-9.989C300.683,174.706,299.502,171.867,297.958,169.475z"></path> </g> <g> <circle style="fill:#48793E;" cx="154.893" cy="209.476" r="23.609"></circle> </g> <g> <path style="fill:#48793E;" d="M85.793,133.087c-0.794,1.72-1.72,3.373-2.646,5.027v0.066c-1.191,1.852-2.381,3.572-3.77,5.292 c-4.697,6.085-10.65,11.245-17.661,15.015c-2.91,1.654-6.02,3.043-9.261,4.101c-1.323,0.397-2.712,0.795-4.101,1.191 c-1.389,0.33-2.778,0.595-4.167,0.86l-2.91-11.708l-1.058-4.101l-0.992-4.167l-9.723-38.96l59.003-14.684 c0.397,1.323,0.794,2.646,1.124,4.035c0.397,1.389,0.662,2.778,0.926,4.167C92.605,111.06,90.754,122.834,85.793,133.087z"></path> </g> <g> <path style="fill:#48793E;" d="M145.792,320.508c0.345,1.384,0.632,2.772,0.871,4.163L87.712,339.35l-14.679-58.951 c1.331-0.438,2.692-0.836,4.085-1.183c1.384-0.345,2.772-0.632,4.162-0.871c27.579-4.736,54.58,11.499,63.33,38.078 C145.05,317.763,145.448,319.124,145.792,320.508z"></path> </g> <g> <path style="fill:#48793E;" d="M468.517,59.003c-1.389,0.396-2.712,0.793-4.101,1.124c-1.389,0.397-2.778,0.662-4.167,0.926 c-11.973,2.05-23.813,0.132-34.132-4.895c-3.241-1.521-6.284-3.374-9.128-5.556c-9.128-6.681-16.272-16.206-20.042-27.65 c-0.463-1.323-0.86-2.712-1.191-4.101c-0.397-1.389-0.662-2.778-0.926-4.167l53.711-13.361L453.832,0l2.183,8.797 L468.517,59.003z"></path> </g> <g> <path style="fill:#48793E;" d="M497.321,174.748L512,233.699l-58.951,14.679c-0.441-1.34-0.838-2.701-1.183-4.085 c-0.345-1.384-0.632-2.772-0.871-4.163c-4.736-27.579,11.499-54.579,38.078-63.329c1.331-0.438,2.692-0.836,4.085-1.183 C494.542,175.275,495.93,174.987,497.321,174.748z"></path> </g> <g> <circle style="fill:#48793E;" cx="387.221" cy="151.625" r="23.609"></circle> </g> </g> <g> <g> <rect x="26.844" y="102.305" transform="matrix(0.9704 -0.2416 0.2416 0.9704 -45.6392 64.7579)" style="fill:#91B78B;" width="428.745" height="232.315"></rect> <path style="fill:#48793E;" d="M472.751,243.486l-0.992-4.166l-1.058-4.102l-2.91-11.708l-6.549-26.393l-22.291-89.364 l-12.832-51.594l-1.852-7.342l-7.276,1.786l-51.661,12.898L85.793,133.087l-26.856,6.681l-11.444,2.844l-4.167,1.059 l-4.101,0.992L0,154.452l14.685,58.937l28.774,115.757l10.055,40.349l4.63,18.654l11.245-2.779l47.758-11.907l306.325-76.333 l59.003-14.684L472.751,243.486z M79.376,143.473l160.339-39.953l27.649-6.88l100.014-24.938l50.669-12.633l12.634,50.734 l24.408,97.897l4.432,17.859l2.91,11.708l1.058,4.101l0.992,4.167l7.673,30.758l-50.734,12.634l-306.392,76.267L64.361,377.83 l-12.634-50.734l-28.84-115.757L10.253,160.67l31.023-7.739l4.167-0.992l4.101-1.059l11.444-2.844L79.376,143.473z"></path> </g> <g> <g> <path style="fill:#48793E;" d="M258.901,289.483c-39.161,9.751-78.953-14.175-88.705-53.336 c-9.751-39.161,14.175-78.953,53.336-88.705c39.161-9.751,78.953,14.175,88.705,53.336 C321.988,239.939,298.061,279.731,258.901,289.483z"></path> </g> </g> <g> <path style="fill:#91B78B;" d="M268.41,218.253c-1.542-2.386-3.532-4.223-5.965-5.514c-1.977-1.188-4.173-1.952-6.593-2.298 c-2.419-0.346-5.373-0.343-8.861,0.015l-0.674,0.063l-8.418,0.779c-1.627,0.19-3.035,0.171-4.222-0.045 c-0.496-0.086-0.968-0.202-1.421-0.342c-0.627-0.195-1.205-0.439-1.745-0.729c-0.947-0.564-1.679-1.256-2.215-2.071 c-0.529-0.816-0.917-1.704-1.157-2.667c-0.634-2.545-0.266-4.951,1.101-7.224c0.187-0.311,0.396-0.61,0.634-0.89 c1.47-1.813,3.868-3.13,7.19-3.957c1.803-0.449,3.721-0.754,5.757-0.91c0.682-0.053,1.375-0.09,2.083-0.113 c2.824-0.081,5.645,0.693,8.459,2.326l6.833-11.225c-3.928-2.303-7.942-3.636-12.046-4c-2.631-0.231-5.469-0.134-8.499,0.306 c-0.491-1.724-1.62-3.118-3.066-3.982c-1.507-0.911-3.363-1.243-5.195-0.787c-3.663,0.912-5.92,4.657-5.006,8.326l0.1,0.4 c-0.845,0.438-1.652,0.904-2.419,1.409c-2.886,1.882-5.183,4.079-6.893,6.58c-1.709,2.506-2.814,5.262-3.304,8.265 c-0.495,3.004-0.326,6.157,0.495,9.455c1.556,6.249,4.504,10.624,8.842,13.114c2.046,1.171,4.32,1.971,6.835,2.404 c1.986,0.336,4.24,0.44,6.783,0.293c0.687-0.036,1.388-0.087,2.116-0.158l9.092-0.842c1.022-0.101,1.907-0.155,2.66-0.17 c0.669-0.007,1.234,0.013,1.692,0.071c0.978,0.12,1.929,0.431,2.859,0.926c1.884,1.137,3.148,2.977,3.781,5.516 c0.736,2.956,0.199,5.497-1.605,7.62c-0.693,0.825-1.579,1.569-2.652,2.23c-1.706,1.059-3.887,1.916-6.548,2.578 c-2.261,0.563-4.502,0.906-6.713,1.025c-1.075,0.058-2.138,0.064-3.202,0.021c-3.242-0.141-6.321-1.085-9.239-2.839 l-6.966,11.578c4.478,2.757,9.071,4.291,13.786,4.613c2.806,0.194,5.763,0.079,8.873-0.338c0.966,3.582,4.668,5.769,8.285,4.868 c3.669-0.914,5.918-4.662,5.006-8.326l-0.023-0.093c1.275-0.564,2.497-1.194,3.667-1.886c3.086-1.821,5.608-3.982,7.577-6.479 c1.97-2.497,3.299-5.291,3.989-8.38c0.69-3.09,0.587-6.419-0.302-9.989C271.134,223.484,269.953,220.645,268.41,218.253z"></path> </g> <g> <circle style="fill:#48793E;" cx="125.344" cy="258.255" r="23.609"></circle> </g> <g> <path style="fill:#48793E;" d="M61.715,158.487c-0.066,7.673-1.786,15.148-4.829,21.96c-0.86,1.985-1.852,3.903-2.91,5.756 c-0.992,1.654-2.051,3.307-3.241,4.828c-6.681,9.26-16.272,16.471-27.848,20.308c-1.323,0.463-2.646,0.859-4.035,1.19h-0.066 c-1.389,0.331-2.778,0.661-4.101,0.86L0,154.452l39.225-9.79l4.101-0.992l4.167-1.059l11.444-2.844 c0.463,1.323,0.86,2.712,1.19,4.101c0.331,1.389,0.595,2.779,0.86,4.167C61.583,151.542,61.847,155.048,61.715,158.487z"></path> </g> <g> <path style="fill:#48793E;" d="M117.146,373.464l-47.758,11.907l-11.245,2.779l-4.63-18.654l-10.055-40.349 c1.389-0.396,2.712-0.794,4.101-1.125c1.389-0.397,2.778-0.661,4.167-0.925c11.972-2.051,23.813-0.132,34.132,4.895 c3.242,1.521,6.284,3.373,9.128,5.555c9.128,6.681,16.272,16.206,20.043,27.65c0.463,1.323,0.86,2.712,1.191,4.101 C116.617,370.686,116.881,372.075,117.146,373.464z"></path> </g> <g> <path style="fill:#48793E;" d="M424.264,48.799l14.679,58.951c-1.341,0.441-2.701,0.838-4.085,1.183 c-1.393,0.347-2.782,0.634-4.163,0.871c-27.579,4.736-54.58-11.498-63.329-38.078c-0.441-1.34-0.838-2.701-1.183-4.085 c-0.345-1.384-0.632-2.772-0.871-4.163L424.264,48.799z"></path> </g> <g> <path style="fill:#48793E;" d="M467.772,223.526l14.679,58.951L423.5,297.157c-0.441-1.34-0.838-2.701-1.182-4.085 c-0.345-1.384-0.632-2.772-0.871-4.163c-4.736-27.579,11.499-54.579,38.078-63.329c1.331-0.438,2.692-0.836,4.085-1.182 C464.993,224.053,466.382,223.766,467.772,223.526z"></path> </g> <g> <circle style="fill:#48793E;" cx="357.673" cy="200.403" r="23.609"></circle> </g> </g> </g> <path style="opacity:0.06;fill:#040000;" d="M497.29,182.789l-28.773-115.75l-12.502-50.206l-2.183-8.798l-5.011,1.253 L63.167,394.943l6.221-1.537l47.758-11.907l306.326-76.332l0.02-0.005c0.003,0.01,0.006,0.019,0.009,0.031l58.952-14.68 l-0.006-0.024l0.029-0.007l-9.723-38.961l23.03-5.747L512,241.735l-14.679-58.952C497.31,182.784,497.3,182.788,497.29,182.789z"></path> </g> </g></svg>
          </button>
        </div>

        <div class="basis-1/3 flex flex-col items-center justify-center">
          <button
            type="button"
            phx-click="service_casted"
            phx-value-entity={:credit_card}
            value={:val_test}
            class="inline-block rounded border-2 border-success w-3/3 px-2 pb-[6px] pt-2 text-xs font-medium uppercase leading-normal text-success transition duration-150 ease-in-out hover:border-success-600 hover:bg-neutral-500 hover:bg-opacity-10 hover:text-success-600 focus:border-success-600 focus:text-success-600 focus:outline-none focus:ring-0 active:border-success-700 active:text-success-700 dark:hover:bg-neutral-100 dark:hover:bg-opacity-10"
          >
          <svg height="40px" width="40px" viewBox="0 0 128 128" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" role="img" class="iconify iconify--noto" preserveAspectRatio="xMidYMid meet" fill="#000000"><g id="SVGRepo_bgCarrier" stroke-width="0"></g><g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g><g id="SVGRepo_iconCarrier"><path d="M116.34 101.95H11.67c-4.2 0-7.63-3.43-7.63-7.63V33.68c0-4.2 3.43-7.63 7.63-7.63h104.67c4.2 0 7.63 3.43 7.63 7.63v60.64c0 4.2-3.43 7.63-7.63 7.63z" fill="#ffc107"></path><path fill="#424242" d="M4.03 38.88h119.95v16.07H4.03z"></path><path d="M114.2 74.14H13.87c-.98 0-1.79-.8-1.79-1.79v-8.41c0-.98.8-1.79 1.79-1.79H114.2c.98 0 1.79.8 1.79 1.79v8.41c-.01.98-.81 1.79-1.79 1.79z" fill="#ffffff"></path><path d="M23.98 70.49c.56-1.08.71-2.34 1.21-3.45c.5-1.11 1.59-2.14 2.79-1.95c1.11.18 1.8 1.29 2.21 2.33c.57 1.45.88 3 .92 4.56c.01.32-.01.67-.22.92c-.37.42-1.13.21-1.42-.27c-.29-.48-.22-1.09-.09-1.64c.62-2.55 2.62-4.72 5.11-5.54c.26-.09.53-.16.8-.11c.58.11.9.71 1.16 1.23c.61 1.19 1.35 2.32 2.2 3.35c.34.42.73.83 1.25.99c1.71.5 2.7-2.02 4.35-2.69c1.98-.8 3.91 1.29 6.01 1.68c3.07.57 4.7-1.82 7.39-2.43c.36-.08.75-.13 1.11-.03c.66.19 1.07.82 1.46 1.39c.91 1.34 2.21 2.66 3.83 2.67c1.03.01 1.98-.52 2.92-.97c3.33-1.59 7.26-2.25 10.74-1.03" fill="none" stroke="#424242" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" stroke-miterlimit="10"></path></g></svg>
          </button>
        </div>

        <div class="basis-1/3 flex flex-col items-center justify-center">
          <button
            type="button"
            phx-click="service_casted"
            phx-value-entity={:beer}
            value={:val_test}
            class="inline-block rounded border-2 border-success w-3/3 px-2 pb-[6px] pt-2 text-xs font-medium uppercase leading-normal text-success transition duration-150 ease-in-out hover:border-success-600 hover:bg-neutral-500 hover:bg-opacity-10 hover:text-success-600 focus:border-success-600 focus:text-success-600 focus:outline-none focus:ring-0 active:border-success-700 active:text-success-700 dark:hover:bg-neutral-100 dark:hover:bg-opacity-10"
          >
          <svg height="40px" width="40px" version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 297 297" xml:space="preserve" fill="#000000"><g id="SVGRepo_bgCarrier" stroke-width="0"></g><g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g><g id="SVGRepo_iconCarrier"> <g> <g> <g> <circle style="fill:#C63C22;" cx="148.5" cy="148.5" r="148.5"></circle> </g> </g> <path style="fill:#9E231D;" d="M296.703,139.216l-96.66-96.678L95.112,242.358l54.626,54.626C231.181,296.318,297,230.1,297,148.5 C297,145.381,296.892,142.288,296.703,139.216z"></path> <g> <path style="fill:#FFFFFF;" d="M207.444,99.107c9.143,0,16.556-7.412,16.556-16.556s-7.412-16.556-16.556-16.556 c-0.233,0-0.459,0.025-0.689,0.035c0.446-1.863,0.689-3.805,0.689-5.805c0-13.715-11.118-24.833-24.833-24.833 c-8.456,0-15.919,4.23-20.404,10.685c-2.92-2.582-6.747-4.163-10.951-4.163c-3.669,0-7.048,1.208-9.793,3.228 c-4.538-5.926-11.683-9.751-19.724-9.751c-10.476,0-19.43,6.491-23.079,15.667c-2.156-1.028-4.559-1.62-7.106-1.62 C82.412,49.44,75,56.852,75,65.996s7.412,16.556,16.556,16.556L207.444,99.107z"></path> </g> <g> <path style="fill:#D0D5D9;" d="M207.444,65.996c-0.233,0-0.459,0.025-0.689,0.035c0.446-1.863,0.689-3.805,0.689-5.804 c0-13.715-11.118-24.833-24.833-24.833c-8.455,0-15.919,4.23-20.404,10.685c-2.92-2.583-6.747-4.163-10.951-4.163 c-0.882,0-1.745,0.073-2.589,0.208V90.71l58.777,8.397c9.143,0,16.556-7.412,16.556-16.556S216.588,65.996,207.444,65.996z"></path> </g> <g> <path style="fill:#F0DEB4;" d="M238.282,115.5H206.25v-33H90.75v148.792c0,8.952,7.257,16.208,16.208,16.208h83.083 c8.952,0,16.208-7.257,16.208-16.208V198h32.032c5.091,0,9.218-4.127,9.218-9.218v-64.064 C247.5,119.627,243.373,115.5,238.282,115.5z M235.853,177.032c0,3.71-3.008,6.718-6.718,6.718h-19.488v-54h19.488 c3.71,0,6.718,3.008,6.718,6.718V177.032z"></path> </g> <g> <path style="fill:#D8C49C;" d="M238.282,115.5H206.25v-33h-57.583v165h41.375c8.952,0,16.208-7.257,16.208-16.208V198h32.032 c5.091,0,9.218-4.127,9.218-9.218v-64.064C247.5,119.627,243.373,115.5,238.282,115.5z M235.853,177.032 c0,3.71-3.008,6.718-6.718,6.718h-19.488v-54h19.488c3.71,0,6.718,3.008,6.718,6.718V177.032z"></path> </g> <g> <path style="fill:#FFA800;" d="M111.814,237.857h73.372c7.905,0,14.314-6.409,14.314-14.314v-92.4h-102v92.4 C97.5,231.449,103.909,237.857,111.814,237.857z"></path> </g> <g> <path style="fill:#CE8400;" d="M148.667,131.143v106.714h36.519c7.905,0,14.314-6.409,14.314-14.314v-92.4H148.667z"></path> </g> </g> </g></svg>
          </button>
        </div>
      </div>

      <div class="grid justify-center mx-auto text-center md:grid-cols-3 lg:grid-cols-3 gap-10 lg:gap-10 my-10 text-white">
        <div class="basis-1/3 flex flex-col items-center justify-center">
          <FullNewsfeedWeb.MainComponents.bank_card bank_data={@bank_data} />
        </div>
        <div class="basis-1/3 flex flex-col items-center justify-center">
          <FullNewsfeedWeb.MainComponents.cc_card cc_data={@cc_data} />
        </div>
        <div class="basis-1/3 flex flex-col items-center justify-center">
          <FullNewsfeedWeb.MainComponents.beer_card beer_data={@beer_data} />
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
      |> Account.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def fetch_bank do
    {:ok, resp} =
      Finch.build(
        :get,
        "https://random-data-api.com/api/v2/banks",
        [{"Accept", "application/json"}]
        )
        |> Finch.request(FullNewsfeed.Finch)

    IO.inspect(resp, label: "Resp")

    {:ok, body} = Jason.decode(resp.body)
    IO.inspect(body, label: "Body")
    body
  end

  def fetch_beer do
    {:ok, resp} =
      Finch.build(
        :get,
        "https://random-data-api.com/api/v2/beers",
        [{"Accept", "application/json"}]
        )
        |> Finch.request(FullNewsfeed.Finch)

    IO.inspect(resp, label: "Resp")

    {:ok, body} = Jason.decode(resp.body)
    IO.inspect(body, label: "Body")
    body |> Beer.new()
  end

  @impl true
  def handle_event("service_casted", params, socket) do
    IO.inspect(socket, label: "Socket")
    data =
      case String.to_existing_atom(params["entity"]) do
        # GenServer.cast String.to_existing_atom(params["castto"]), {String.to_existing_atom(params["op"]), String.to_existing_atom(params["res"])}
        :bank -> fetch_bank()
        :credit_card -> "Credit Card Data"
        :beer -> fetch_beer()
        _ -> raise "No ID Match for find_nearest()"
      end
    IO.inspect(data, label: "Data")
    data_label = String.to_existing_atom(params["entity"] <> "_data")
    {:noreply,
      socket
      |> assign(data_label, data)}
      # |> assign(bank_data: data)
      # |> assign(beer_data: data)}
  end

  def save_beer(beer_struct, user_id) do
    item_hold = %Hold{slug: UUID.generate(), user_id: user_id, hold_cat: :beer, type: :favorite, hold_cat_id: UUID.generate(), active: true}
    Repo.insert(item_hold)
  end

  def save_bank(bank_struct) do
    Repo.insert(bank_struct)
  end

  @impl true
  def handle_event("save_item", params, socket) do
    res =
      case String.to_existing_atom(params["entity"]) do
        # GenServer.cast String.to_existing_atom(params["castto"]), {String.to_existing_atom(params["op"]), String.to_existing_atom(params["res"])}
        :bank -> save_bank(socket.assigns.bank_data)
        :credit_card -> {:ok, "Credit Card Data"}
        :beer -> save_beer(socket.assigns.beer_data, socket.assigns.current_user.id)
        _ -> raise "No ID Match for save_item()"
      end
    msg =
      case res do
        {:ok, _} -> "Record Updated"
        {:error, err} -> "Error: #{err}"
      end
    {:noreply,
      socket
      |> assign(:alert, msg)}
  end

  @impl true
  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Account.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Account.deliver_user_update_email_instructions(
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

  # def handle_event("new_message", params, socket) do
  #   {:noreply, socket}
  # end
end
