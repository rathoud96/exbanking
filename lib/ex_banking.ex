defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """

  alias ExBanking.User


  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) when is_binary(user) do
    case ExBanking.UserSupervisor.create_user(user) do
      {:ok, _pid} -> :ok
      error -> error
    end
  end

  def create_user(_) do
    {:error, :wrong_arguments}
  end


  @spec get_balance(user :: String.t, currency :: String.t) :: {:ok, balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) when is_binary(currency) do
    User.get_balance(user, currency)
  end

  def get_balance(_user, _currency) do
    {:error, :wrong_arguments}
  end

  @spec deposit(user :: String.t, amount :: number, currency :: String.t) :: {:ok, new_balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) when amount > 0 do
    User.deposit(user, amount, currency)
  end

  def deposit(_username, _amount, _currency) do
    {:error, :wrong_arguments}
  end

  @spec withdraw(user :: String.t, amount :: number, currency :: String.t) :: {:ok, new_balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :not_enough_money | :too_many_requests_to_user}
  def withdraw(user, amount, currency) when amount > 0 do
    User.withdraw(user, amount, currency)
  end

  def withdraw(_user, _amount, _currency) do
    {:error, :wrong_arguments}
  end

  @spec send(from_user :: String.t, to_user :: String.t, amount :: number, currency :: String.t) :: {:ok, from_user_balance :: number, to_user_balance :: number} | {:error, :wrong_arguments | :not_enough_money | :sender_does_not_exist | :receiver_does_not_exist | :too_many_requests_to_sender | :too_many_requests_to_receiver}
  def send(from_user, to_user, amount, currency) when amount > 0 do
    User.send(from_user, to_user, amount, currency)
  end

  def send(_from_user, _to_user, _amount, _currency) do
    {:error, :wrong_arguments}
  end
end
