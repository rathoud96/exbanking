defmodule ExBanking.User do
  use GenServer

  @error_messages [
    default_user_error: :user_does_not_exist,
    default_request_error: :too_many_requests_to_user,
    sender_error: :sender_does_not_exist,
    receiver_error: :receiver_does_not_exist,
    sender_request_error: :too_many_requests_to_sender,
    receiver_request_error: :too_many_requests_to_receiver
  ]

  def start_link(user) do
    case GenServer.start_link(__MODULE__, [],
      name: {:via, Registry, {ExBanking.UserRegistery, user}}
    ) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, _pid}} -> {:error, :user_already_exist}
    end
  end

  def init(_) do
    {:ok, %{account: %{}}}
  end

  def get_balance(user, currency) do
    with {:ok, pid} <- user_exists?(user),
    :ok <- perform_request?(pid) do
      GenServer.call(pid, {:get_balance, currency})
    end
  end

  def withdraw(user, amount, currency) do
    with {:ok, pid} <- user_exists?(user),
    :ok <- perform_request?(pid) do
      GenServer.call(pid, {:withdraw, amount, currency})
    end
  end

  def deposit(user, amount, currency) do
    with {:ok, pid} <- user_exists?(user),
    :ok <- perform_request?(pid) do
      GenServer.call(pid, {:deposit, amount, currency})
    end
  end

  def send(sender, receiver, amount, currency) do
    with {:ok, sender_pid} <- user_exists?(sender, :sender_error),
      {:ok, receiver_pid} <- user_exists?(receiver, :receiver_error),
      :ok <- perform_request?(sender_pid, :too_many_requests_to_sender),
      :ok <- perform_request?(receiver_pid, :too_many_requests_to_receiver),
      {:ok, sender_balance} <- GenServer.call(sender_pid, {:withdraw, amount, currency}),
      {:ok, receiver_balance} <- GenServer.call(receiver_pid, {:deposit, amount, currency}) do
        {:ok, sender_balance, receiver_balance}
    end
  end

  def handle_call({:get_balance, currency}, _from, state) do
    current_balance = Map.get(state.account, currency)

    case current_balance do
      nil ->
        {:reply, {:error, :wrong_arguments}, state}
      _ ->
        {:reply, {:ok, current_balance}, state}
    end
  end

  def handle_call({:withdraw, amount, currency}, _from, state) do
    current_balance = Map.get(state.account, currency)

    cond do
      is_nil(current_balance) ->
        {:reply, {:error, :wrong_arguments}, state}
      current_balance < amount ->
        {:reply, {:error, :not_enough_money}, state}
      true ->
        new_balance = current_balance - amount
          |> :erlang.float()
          |> Float.round(2)

        {:reply, {:ok, new_balance}, %{account: Map.put(state.account, currency, new_balance)}}
    end
  end

  def handle_call({:deposit, amount, currency}, _from, state) do
    current_balance = Map.get(state.account, currency, 0.0)

    new_balance = current_balance + amount
      |> :erlang.float()
      |> Float.round(2)

    {:reply, {:ok, new_balance}, %{account: Map.put(state.account, currency, new_balance)}}
  end

  defp user_exists?(user, error_message \\ :default_user_error) do
    case Registry.lookup(ExBanking.UserRegistery, user) do
      [] ->
        {:error, Keyword.get(@error_messages, error_message)}
      [{pid, _}] ->
        {:ok, pid}
    end
  end

  defp perform_request?(pid, error_message \\ :default_request_error) do
    case :erlang.process_info(pid, :message_queue_len) do
      {:message_queue_len, length} when length < 10 ->
        :ok
      _ ->
        {:error, Keyword.get(@error_messages, error_message)}
    end
  end
end
