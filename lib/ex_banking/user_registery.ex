defmodule ExBanking.UserRegistery do
  @moduledoc false

  def child_spec do
    Registry.child_spec(
      keys: :unique,
      name: __MODULE__
    )
  end
end
