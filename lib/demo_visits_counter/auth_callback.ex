defmodule DemoVisitsCounter.AuthCallback do
  import Plug.Conn

  require Logger

  alias DomaOAuth.Authentication.{Success, Failure}

  alias DemoVisitsCounter.Identity

  def call(%{assigns: %{oauth: %Success{} = success}} = conn, _opts) do
    Logger.info("[#{__MODULE__}] Successful authentication attempt: #{inspect(success)}")

    case DemoVisitsCounter.get_identity(success.hashed_identity) do
      {:ok, _pid} ->
        current_login_counter = Identity.increment_login_counter(success.hashed_identity)

        msg =
          "Successful authentication attempt for hashed identity: #{success.hashed_identity}\nLogin counter: #{current_login_counter}"

        conn
        |> fetch_session()
        |> put_session(:hashed_identity, success.hashed_identity)
        |> send_resp(200, msg)
        |> halt()

      {:error, :not_found} ->
        {:ok, _pid} = DemoVisitsCounter.spawn_identity(success)

        msg =
          "Successful authentication attempt. New identity added!\nHashed identity: #{success.hashed_identity}"

        conn
        |> fetch_session()
        |> put_session(:hashed_identity, success.hashed_identity)
        |> send_resp(200, msg)
        |> halt()
    end
  end

  def call(%{assigns: %{oauth: %Failure{} = fail}} = conn, _opts) do
    Logger.info("[#{__MODULE__}] Failed authentication attempt: #{inspect(fail)}")

    conn
    |> send_resp(403, "Failed authentication attempt: #{inspect(fail)}")
    |> halt()
  end

  def call(conn, opts) do
    IO.inspect(conn, label: "conn")
    IO.inspect(opts, label: "opts")

    conn
    |> send_resp(500, "Something went wrong")
    |> halt()
  end

  def authenticated?(conn) do
    conn
    |> get_session(:hashed_identity)
    |> DemoVisitsCounter.get_identity()
    |> case do
      {:ok, _pid} -> true
      _ -> false
    end
  end
end
