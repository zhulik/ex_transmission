defmodule Transmission.Client do
  use Tesla

  def auth_token(client) do
    case Tesla.post(client.tesla, "/", %{},
           headers: [{"Content-Type", "application/json"}, auth_header(client)]
         ) do
      {:ok, %Tesla.Env{headers: headers, status: 409}} ->
        {:ok, Enum.into(headers, %{})["x-transmission-session-id"]}

      {:ok, %Tesla.Env{status: 401}} ->
        {:error, :invalid_credentials}

      {:error, data} ->
        {:error, data}
    end
  end

  defp auth_header(client) do
    {"Authorization", "Basic #{Base.encode64("#{client.username}:#{client.password}")}"}
  end
end
