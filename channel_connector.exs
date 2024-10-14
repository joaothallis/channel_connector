Mix.install([{:phoenix_playground, "~> 0.1.6"}, {:tesla, "~> 1.12"}])

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
    send_message_to_channel(message)
    updated_inbound_messages = [message | socket.assigns.inbound_messages]
    {:noreply, assign(socket, inbound_messages: updated_inbound_messages)}
  end

  # https://whatsapp.turn.io/docs/api/channel_api#sending-inbound-messages-to-your-channel
  defp send_message_to_channel(message) do
    channel = System.fetch_env!("CHANNEL")

    {:ok, %Tesla.Env{status: 200}} =
      __MODULE__.Turn.post("/v1/numbers/#{channel}/messages", %{
        contact: %{id: "the-user-id", profile: %{name: "User"}},
        message: %{
          type: "text",
          text: message,
          from: "the-user-id",
          id: :crypto.strong_rand_bytes(16) |> Base.encode16(),
          timestamp: DateTime.to_unix(DateTime.utc_now())
        }
      })
  end

  defmodule Turn do
    use Tesla

    @turn_url System.get_env("TURN_URL", "https://whatsapp.turn.io/")

    plug(Tesla.Middleware.BaseUrl, @turn_url)
    plug(Tesla.Middleware.JSON)
    plug(Tesla.Middleware.BearerAuth, token: System.fetch_env!("TURN_TOKEN"))
  end
end

PhoenixPlayground.start(live: ChannelConnector)
