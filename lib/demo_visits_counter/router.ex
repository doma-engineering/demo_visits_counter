defmodule DemoVisitsCounter.Router do
  use Plug.Router

  plug(Plug.Logger)

  @session_options [
    store: :cookie,
    key: "_my_app_session",
    encryption_salt: "cookie store encryption salt",
    signing_salt: "cookie store signing salt",
    secret_key_base: "oEmi0qbPX1iNGLuG9sSZB+WxbxR99eXznc8nhUf+d8tBv/VxkTYKkFPpMIDLvltG",
    log: :debug
  ]

  plug(Plug.Session, @session_options)

  plug(:fetch_query_params)

  plug(:match)
  plug(Ueberauth)
  plug(:dispatch)

  plug(:fetch_session)

  get("/auth/:provider/callback",
    to: DomaOAuth,
    init_opts: %{callback: &DemoVisitsCounter.AuthCallback.call/2}
  )

  get "/protected" do
    fetched = fetch_session(conn)

    if DemoVisitsCounter.AuthCallback.authenticated?(fetched) do
      hashed_identity = get_session(fetched, :hashed_identity)
      count = DemoVisitsCounter.Identity.increment_page_visits_counter(hashed_identity)

      fetched
      |> send_resp(200, "You are authenticated. Page views count: #{count}")
      |> halt()
    else
      fetched
      |> send_resp(403, "You are not authenticated!")
      |> halt()
    end
  end

  get "/clear_session" do
    conn
    |> fetch_session()
    |> clear_session()
    |> send_resp(200, "Session cleared")
    |> halt()
  end

  get "/" do
    conn
    |> send_resp(202, "hello world")
    |> halt()
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
