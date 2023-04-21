defmodule DemoVisitsCounter.Identity do
  use GenServer

  defstruct [:identity, :hashed_identity, login_counter: 0, page_visits_counter: 0]

  alias DomaOAuth.Authentication.Success

  # Public API

  def start_link(%Success{hashed_identity: hashed_identity} = success_struct) do
    GenServer.start_link(__MODULE__, success_struct, name: via_tuple(hashed_identity))
  end

  @spec increment_login_counter(binary()) :: :ok
  def increment_login_counter(hashed_identity) do
    hashed_identity
    |> via_tuple()
    |> GenServer.call({:increment_counter, :login})
  end

  @spec increment_page_visits_counter(binary()) :: :ok
  def increment_page_visits_counter(hashed_identity) do
    hashed_identity
    |> via_tuple()
    |> GenServer.call({:increment_counter, :page_visits})
  end

  # Callbacks

  @impl GenServer
  def init(success) do
    {:ok, %__MODULE__{identity: success.identity, hashed_identity: success.hashed_identity}}
  end

  @impl GenServer
  def handle_call({:increment_counter, :login}, _from, state) do
    incremented_login_counter = state.login_counter + 1

    {:reply, incremented_login_counter, %{state | login_counter: incremented_login_counter}}
  end

  def handle_call({:increment_counter, :page_visits}, _from, state) do
    incremented_page_visits_counter = state.page_visits_counter + 1

    {:reply, incremented_page_visits_counter,
     %{state | page_visits_counter: state.page_visits_counter + 1}}
  end

  defp via_tuple(hashed_identity) do
    {:via, Registry, {DemoVisitsCounter.Registry, hashed_identity}}
  end
end
