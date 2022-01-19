defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  # API
  def create_user(username) when is_binary(username) do
    User.create(String.to_atom(username))
  end

  def create_user(_) do
    {:error, :wrong_arguments}
  end

  def get_balance(user, currency) do
    User.get_balance(String.to_atom(user), currency)
  end

  def deposit(_user, amount, _currency) when amount < 0 do
    {:error, :wrong_arguments}
  end

  def deposit(user, amount, currency) do
    User.deposit(String.to_atom(user), amount, currency)
  end

  def withdraw(_user, amount, _currency) when amount < 0 do
    {:error, :wrong_arguments}
  end

  def withdraw(user, amount, currency) do
    User.withdraw(String.to_atom(user), amount, currency)
  end

  def send(_from_user, _to_user, amount, _currency) when amount < 0 do
    {:error, :wrong_arguments}
  end

  def send(from_user, to_user, amount, currency) do
    User.send(String.to_atom(from_user), String.to_atom(to_user), amount, currency)
  end
end
