defmodule DiscordElixir.RealtimeClient.Helpers do
  @moduledoc """
  Writing a Bot? These helpers should help make it easier.
  """
  alias DiscordElixir.RestClient

  @doc  "This checks that an incoming message is private or is a mention to the defined user"
  @spec actionable_message_for?(String.t, map, map) :: boolean
  def actionable_message_for?(username, payload, state) do
    if payload.data["author"]["username"] != username do
      cond do
        message_in_private_channel?(payload.data["channel_id"], state) ->
          true
        message_mentions_user?(payload.data["mentions"], username) ->
          true
        true ->
          false
      end
    else
      false
    end
  end

  defp message_mentions_user?(mentions, username) do
    Enum.find mentions, fn(m) -> m["username"] == username end
  end

  defp message_in_private_channel?(channel_id, state) do
    state
     |> current_channels("private")
     |> Enum.find(fn(cid) -> String.to_integer(cid) == channel_id end)
  end

  @doc  "Get the current channels of a specific type for a client."
  @spec current_channels(map, String.t) :: list
  def current_channels(state, type \\ "private") do
    private = (type == "private")
    RestClient.resource(state[:rest_client], :get, "users/@me/channels")
    |> Enum.filter(fn(c) -> c["is_private"] == private end)
    |> Enum.map(fn(c) -> c["id"] end)
  end

end
