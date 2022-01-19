defmodule ExBankingTest do
  use ExUnit.Case

  describe "create_user/1" do
    test "success" do
      assert :ok == ExBanking.create_user("test")
    end

    test "failure" do
      ExBanking.create_user("test")
      error_response = ExBanking.create_user("test")

      assert {:error, :user_already_exists} == error_response
    end
  end

  describe "deposit/3" do
    test "success" do
      ExBanking.create_user("test")
      {:ok, balance} = ExBanking.deposit("test", 10.00, "INR")

      assert balance == 10.00
    end

    test "failure" do
      ExBanking.create_user("test")
      response = ExBanking.deposit("test", -10.00, "INR")

      assert {:error, :wrong_arguments} == response
    end
  end

  describe "withdraw/3" do
    test "success" do
      ExBanking.create_user("test")
      {:ok, balance} = ExBanking.deposit("test", 10.00, "INR")

      {:ok, new_balance} = ExBanking.withdraw("test", 5.00, "INR")

      assert new_balance == balance - 5.00
    end

    test "failure - when amount is negative" do
      ExBanking.create_user("test")
      response = ExBanking.withdraw("test", -10.00, "INR")

      assert {:error, :wrong_arguments} == response
    end

    test "failure - when insufficient balance" do
      ExBanking.create_user("test")
      ExBanking.deposit("test", 10.00, "INR")
      response = ExBanking.withdraw("test", 15.00, "INR")

      assert {:error, :not_enough_money} == response
    end

    test "failure - currency is not valid" do
      ExBanking.create_user("test")
      ExBanking.deposit("test", 10.00, "INR")
      response = ExBanking.withdraw("test", 15.00, "INr")

      assert {:error, :wrong_arguments} == response
    end

    test "failure - when user not exist" do
      response = ExBanking.withdraw("test", 15.00, "INr")

      assert {:error, :user_does_not_exists} == response
    end
  end

  describe "send/4" do
    test "success" do
      ExBanking.create_user("test1")
      ExBanking.create_user("test2")
      amount = 10.00
      {:ok, sender_balance} = ExBanking.deposit("test1", amount, "INR")
      {:ok, receiver_balance} = ExBanking.deposit("test2", amount, "INR")

      {:ok, sender_new_balance, receiver_new_balance} =
        ExBanking.send("test1", "test2", amount, "INR")

      assert sender_new_balance == sender_balance - amount
      assert receiver_new_balance == receiver_balance + amount
    end

    test "failure - sender does not exists" do
      assert {:error, :sender_does_not_exist} == ExBanking.send("test1", "test2", 10.00, "INR")
    end

    test "failure - receiver does not exists" do
      ExBanking.create_user("test1")
      amount = 10.00
      ExBanking.deposit("test1", amount, "INR")

      assert {:error, :receiver_does_not_exist} == ExBanking.send("test1", "test2", amount, "INR")
    end

    test "failure - sender insufficient balance" do
      ExBanking.create_user("user1")
      ExBanking.create_user("user2")
      amount = 10.00
      ExBanking.deposit("user1", amount, "INR")
      ExBanking.deposit("user2", amount, "INR")

      assert {:error, :not_enough_money} ==
               ExBanking.send("user1", "user2", amount + 10.00, "INR")
    end

    test "failure - wrong arguments" do
      ExBanking.create_user("user1")
      ExBanking.create_user("user2")
      amount = 10.00
      ExBanking.deposit("user1", amount, "INR")
      ExBanking.deposit("user2", amount, "INR")

      assert {:error, :wrong_arguments} == ExBanking.send("user1", "user2", -10.00, "INR")
    end
  end
end
