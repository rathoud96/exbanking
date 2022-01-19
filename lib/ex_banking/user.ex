defmodule User do
  use GenServer

  def start_link(user) do
    GenServer.start_link(__MODULE__, :ok, name: user)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def create(username) do
    start_link(username)
    GenServer.call(Process.whereis(username), {:create_user, username})
  end

  def get_balance(username, currency) do
    case Process.whereis(username) do
      nil ->
        {:error, :user_does_not_exists}

      pid ->
        GenServer.call(pid, {:get_balance, username, currency})
    end
  end

  def withdraw(username, amount, currency) do
    case Process.whereis(username) do
      nil ->
        {:error, :user_does_not_exists}

      pid ->
        GenServer.call(pid, {:withdraw, username, amount, currency})
    end
  end

  def deposit(username, amount, currency) do
    case Process.whereis(username) do
      nil ->
        {:error, :user_does_not_exists}

      pid ->
        GenServer.call(pid, {:deposit, username, amount, currency})
    end
  end

  def send(sender, receiver, amount, currency) do
    sender_pid = Process.whereis(sender)
    receiver_pid = Process.whereis(receiver)

    cond do
      sender_pid == nil ->
        {:error, :sender_does_not_exist}

      receiver_pid == nil ->
        {:error, :receiver_does_not_exist}

      true ->
        withdraw_response = GenServer.call(sender_pid, {:withdraw, sender, amount, currency})

        deposit_response = GenServer.call(receiver_pid, {:deposit, receiver, amount, currency})

        create_response(withdraw_response, deposit_response)
    end
  end

  def handle_call({:create_user, username}, _from, state) do
    case Map.get(state, username) do
      nil ->
        data = %{
          user: Atom.to_string(username),
          amount: 0,
          currency: nil
        }

        {:reply, :ok, Map.put(state, username, data)}

      _ ->
        {:reply, {:error, :user_already_exists}, state}
    end
  end

  def handle_call({:get_balance, user, currency}, _from, state) do
    {_, len} = Process.info(self(), :message_queue_len)
    user_data = Map.get(state, user)

    cond do
      is_nil(user_data) ->
        {:reply, {:error, :user_does_not_exist}, state}

      len > 10 ->
        {:reply, {:error, :too_many_requests_to_user}, state}

      user_data[:currency] != currency ->
        {:reply, {:error, :wrong_arguments}, state}

      true ->
        {:reply, {:ok, set_precision(user_data[:amount])}, state}
    end
  end

  def handle_call({:withdraw, user, amount, currency}, _from, state) do
    {_, len} = Process.info(self(), :message_queue_len)
    user_data = Map.get(state, user)

    cond do
      len > 10 ->
        {:reply, {:error, :too_many_requests_to_user}, state}

      user_data[:currency] != currency ->
        {:reply, {:error, :wrong_arguments}, state}

      user_data[:amount] < amount ->
        {:reply, {:error, :not_enough_money}, state}

      true ->
        updated_data = Map.put(user_data, :amount, user_data[:amount] - amount)
        {:reply, {:ok, set_precision(updated_data[:amount])}, Map.put(state, user, updated_data)}
    end
  end

  def handle_call({:deposit, user, amount, currency}, _from, state) do
    {_, len} = Process.info(self(), :message_queue_len)
    user_data = Map.get(state, user)

    cond do
      is_nil(user_data) ->
        {:reply, {:error, :user_does_not_exist}, state}

      len > 10 ->
        {:reply, {:error, :too_many_requests_to_user}, state}

      is_nil(user_data[:currency]) ->
        updated_data =
          user_data
          |> Map.put(:amount, user_data[:amount] + amount)
          |> Map.put(:currency, currency)

        {:reply, {:ok, set_precision(updated_data[:amount])}, Map.put(state, user, updated_data)}

      user_data[:currency] == currency ->
        updated_data =
          user_data
          |> Map.put(:amount, user_data[:amount] + amount)

        {:reply, {:ok, set_precision(updated_data[:amount])}, Map.put(state, user, updated_data)}

      user_data[:currency] != currency ->
        {:reply, {:error, :wrong_arguments}, state}
    end
  end

  defp create_response({:error, reason}, _) do
    {:error, reason}
  end

  defp create_response(_, {:error, reason}) do
    {:error, reason}
  end

  defp create_response({:ok, sender_new_balance}, {:ok, receiver_new_balance}) do
    {:ok, sender_new_balance, receiver_new_balance}
  end

  defp set_precision(amount) when is_float(amount) do
    Float.round(amount, 2)
  end

  defp set_precision(amount) do
    amount
  end
end
