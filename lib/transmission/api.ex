defmodule Transmission.Api do
  alias Tesla.Middleware

  @middlewares [
    {Middleware.JSON, engine: Poison, engine_opts: [keys: :atoms]},
    Middleware.Logger,
    {Middleware.Timeout, timeout: 30_000}
  ]

  def new(url, username, password) do
    middleware =
      [
        {Middleware.BaseUrl, url},
        {Middleware.BasicAuth, %{username: username, password: password}}
      ] ++ @middlewares

    Tesla.client(middleware)
  end

  def execute_method(api, token, method) do
    case Tesla.post(
           api,
           "/",
           method,
           headers: [{"X-Transmission-Session-Id", token || ""}]
         ) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {token, body}

      {:ok, %Tesla.Env{status: 409}} ->
        {:ok, token} = auth_token(api)
        execute_method(api, token, method)
    end
  end

  defp auth_token(api) do
    case Tesla.post(api, "/", %{}, headers: [{"Content-Type", "application/json"}]) do
      {:ok, %Tesla.Env{headers: headers, status: 409}} ->
        {:ok, Enum.into(headers, %{})["x-transmission-session-id"]}

      {:ok, %Tesla.Env{status: 401}} ->
        {:error, :invalid_credentials}

      {:error, data} ->
        {:error, data}
    end
  end
end
