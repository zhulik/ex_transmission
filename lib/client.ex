defmodule Transmission.Client do
  defstruct [:tesla, :url, :username, :password, :token]
  use Tesla

  @middleware [
    {Tesla.Middleware.JSON, engine: Poison, engine_opts: [keys: :atoms]},
    Tesla.Middleware.Logger,
    {Tesla.Middleware.Timeout, timeout: 30_000}
  ]

  def new(url, username, password) do
    middleware =
      [
        {Tesla.Middleware.BaseUrl, url}
      ] ++ @middleware

    %__MODULE__{
      tesla: Tesla.client(middleware),
      url: url,
      username: username,
      password: password
    }
  end

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
