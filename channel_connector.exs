Mix.install([{:phoenix_playground, "~> 0.1.6"}])

defmodule ChannelConnector do
  @moduledoc """
  A simple Channel Connector implementation that allows you to send and receive
  messages using Turn Channels API

  """
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, inbound_messages: [], outbound_messages: [])}
  end

  def render(assigns) do
    ~H"""
    <h1>Channel Connector</h1>
    <div>
      <h2>Outbound Messages</h2>
      <pre>
        <%= for message <- @outbound_messages do %>
          <%= message %>
        <% end %>
      </pre>
    </div>
    <div>
      <h2>Inbound Messages</h2>
      <pre>
        <%= for message <- @inbound_messages do %>
          <%= message %>
        <% end %>
      </pre>
    </div>

    <form phx-submit="send_message">
      <input type="text" name="message"/>
      <button type="submit">Send Message</button>
    </form>

    <style type="text/css">
      body {padding: 1em;}
    </style>
    """
  end

  def handle_event("send_message", %{"message" => message}, socket) do
    updated_inbound_messages = [message | socket.assigns.inbound_messages]
    {:noreply, assign(socket, inbound_messages: updated_inbound_messages)}
  end
end

PhoenixPlayground.start(live: ChannelConnector)
