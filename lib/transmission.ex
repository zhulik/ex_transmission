defmodule Transmission do
  defstruct [:tesla, :url, :username, :password, :token]

  @middleware [
    {Tesla.Middleware.JSON, engine: Poison, engine_opts: [keys: :atoms]},
    Tesla.Middleware.Logger,
    {Tesla.Middleware.Timeout, timeout: 30_000}
  ]

  def client(url, username, password) do
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
end
