defmodule FullNewsfeedWeb.MainComponents do
  use Phoenix.Component
  alias FullNewsfeed.Entities.Headline
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
          <button
            type="button"
            phx-click="save_item"
            phx-value-entity={:beer}
            value={:beer_value}
          ><CoreComponents.icon name="hero-star-solid" class="h-3 w-3" /></button>
          <ul class="self-center">
            <li><%= String.capitalize(@beer_data.alcohol) %></li>
            <li><%= String.capitalize(@beer_data.name) %></li>
            <li><%= String.capitalize(@beer_data.brand) %></li>
            <li><%= @beer_data.style %></li>
            <li><%= @beer_data.alcohol %></li>
          </ul>
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
          <button
            type="button"
            phx-click="save_item"
            phx-value-entity={:bank}
            value={:bank_value}
          ><CoreComponents.icon name="hero-star-solid" class="h-3 w-3" /></button>
          <ul class="self-center">
            <li><%= String.capitalize(@bank_data.swift_bic) %></li>
            <li><%= String.capitalize(@bank_data.bank_name) %></li>
            <li><%= String.capitalize(@bank_data.iban) %></li>
          </ul>
        <% end %>
      </div>
    """
  end

  def headlines_card(assigns) do
    ~H"""
      <div class="">
        <div class="justify-self-start"><h4>Headlines</h4></div>
        <div class="justify-self-end"><span class="text-sm"><%= if @headlines_data do %>🟢<% else %>🔴<% end %></span></div>
        <%= if @headlines_data do %>
          <h6>Headlines (<%= Enum.count(@headlines_data) %>) from (<%= Headline.display_source(List.first(@headlines_data).source_id) %>)</h6>
          <%= for headline <- @headlines_data do %>
            <ul class="text-zinc-200 list-none text-sm dark:text-gray-400 border border-sky-800 my-4">
              <button
                type="button"
                phx-click="save_item"
                phx-value-entity={:headline}
                value={Enum.find_index(@headlines_data, fn hl -> hl == headline end)}
              ><CoreComponents.icon name="hero-star-solid" class="h-3 w-3" /></button>
              <li><%= headline.title %></li>
              <li>Author: <%= headline.author %></li>
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
