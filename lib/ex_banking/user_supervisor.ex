defmodule ExBanking.UserSupervisor do
  @moduledoc """
  This module will manage user processes dynamically
  """

  use DynamicSupervisor

  alias ExBanking.User

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def create_user(user) do
    DynamicSupervisor.start_child(__MODULE__, {User, user})
  end
end
