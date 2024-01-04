defmodule FullNewsfeedWeb.MainComponents do
  use Phoenix.Component
  alias FullNewsfeedWeb.CoreComponents
  # alias Phoenix.LiveView.JS

  @spec unicode_display([binary()]) :: binary()
  def unicode_display(unicode) do
    str = String.replace(Enum.at(unicode, 0), "U+", "\\u")
    # List.to_string ["\x{1F54C}"]
    List.to_string [str]
  end

  def beer_card(assigns) do
    ~H"""
      <div class="relative flex">
        <div class="justify-self-start"><h4>Beer</h4></div>
        <div class="justify-self-end"><span class="text-sm"><%= if @beer_data do %>🟢<% else %>🔴<% end %></span></div>
        <%= if @beer_data do %>
          <ul class="self-center">
            <li><%= String.capitalize(@beer_data.uid) %></li>
            <li><%= String.capitalize(@beer_data.name) %></li>
            <li><%= String.capitalize(@beer_data.brand) %></li>
            <li><%= @beer_data.style %></li>
            <li><%= @beer_data.alcohol %></li>
          </ul>
          <button
            type="button"
            phx-click="save_item"
            phx-value-entity={:beer}
            value={:val_test}
            class="rounded border-2 border-success w-3/3 px-2 pb-[6px] pt-2 text-xs font-medium uppercase leading-normal text-success transition duration-150 ease-in-out hover:border-success-600 hover:bg-neutral-500 hover:bg-opacity-10 hover:text-success-600 focus:border-success-600 focus:text-success-600 focus:outline-none focus:ring-0 active:border-success-700 active:text-success-700 dark:hover:bg-neutral-100 dark:hover:bg-opacity-10"
          >Save
        </button>
        <% end %>
      </div>
    """
  end

  def bank_card(assigns) do
    ~H"""
      <div class="relative flex">
        <div class="justify-self-start"><h4>Bank</h4></div>
        <div class="justify-self-end"><span class="text-sm"><%= if @bank_data do %>🟢<% else %>🔴<% end %></span></div>
        <%= if @bank_data do %>
          <ul class="self-center">
            <li><%= String.capitalize(@bank_data.uid) %></li>
            <li><%= String.capitalize(@bank_data.bank_name) %></li>
            <li><%= String.capitalize(@bank_data.account_number) %></li>
          </ul>
        <% end %>
      </div>
    """
  end

  def headlines_card(assigns) do
    ~H"""
      <div class="relative flex">
        <div class="justify-self-start"><h4>Headlines</h4></div>
        <div class="justify-self-end"><span class="text-sm"><%= if @headlines_data do %>🟢<% else %>🔴<% end %></span></div>
        <%= if @headlines_data do %>
          <h6>Headlines <%= Enum.count(@headlines_data) %></h6>
          <%= for headline <- @headlines_data do %>
            <ul class="self-center">
              <li><%= headline.title %></li>
            </ul>
          <% end %>
        <% end %>
      </div>
    """
  end

  def streamer_card(assigns) do
    ~H"""
    <div class="relative flex">
      <div class="justify-self-start"><h4>Streamer</h4></div>
      <div class="justify-self-end"><span class="text-xs"><%= if @streamer_svg do %>🟢<% else %>🔴<% end %></span></div>
        <%= if @streamer_svg do %><%= @streamer_svg %><% end %>
    </div>
    """
  end

  def xml_card(assigns) do
    ~H"""
    <div class="relative flex">
      <%= if @xml_data && List.first(@xml_data) do %>
        <div :for={town <- @xml_data}>
          <p><%= town.town %></p>
        </div>
      <% end %>
    </div>
    """
  end
end
