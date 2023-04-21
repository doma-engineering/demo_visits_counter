defmodule DemoVisitsCounter do
  @moduledoc false

  alias DomaOAuth.Authentication.Success
  alias DemoVisitsCounter.Identity

  def spawn_identity(%Success{} = success_struct) do
    DynamicSupervisor.start_child(DemoVisitsCounter.DynamicSupervisor, {Identity, success_struct})
  end

  def get_identity(hashed_identity) do
    case Registry.lookup(DemoVisitsCounter.Registry, hashed_identity) do
      [{pid, _}] when is_pid(pid) ->
        {:ok, pid}

      _ ->
        {:error, :not_found}
    end
  end
end
