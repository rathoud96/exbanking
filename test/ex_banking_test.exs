defmodule ExBankingTest do
  use ExUnit.Case

  describe "create_user/1" do
    test "successfully create user" do
      assert :ok == ExBanking.create_user("test")
    end

    test "user already exist" do
      ExBanking.create_user("Bar")
      error_response = ExBanking.create_user("Bar")

      assert {:error, :user_already_exist} == error_response
    end
  end

  describe "deposit/3" do
    test "successfully depost money" do
      ExBanking.create_user("test1")
      {:ok, balance} = ExBanking.deposit("test1", 10.00, "INR")

      assert balance == 10.00
    end

    test "failed to deposit money -> negative amount" do
      ExBanking.create_user("test2")
      response = ExBanking.deposit("test2", -10.00, "INR")

      assert {:error, :wrong_arguments} == response
    end

    test "failed to deposit money -> user does not exist" do
      response = ExBanking.deposit("Foo", 10.00, "INR")

      assert {:error, :user_does_not_exist} == response
    end
  end

  describe "withdraw/3" do
    test "successfully withdraw money" do
      ExBanking.create_user("test3")
      amount = 10
      ExBanking.deposit("test3", amount, "INR")

      {:ok, new_balance} = ExBanking.withdraw("test3", 5.00, "INR")

      assert new_balance == amount - 5.00
    end

    test "failed to withdraw money -> when amount is negative" do
      ExBanking.create_user("test4")
      response = ExBanking.withdraw("test4", -10.00, "INR")

      assert {:error, :wrong_arguments} == response
    end

    test "failed to withdraw money -> when insufficient balance" do
      ExBanking.create_user("test5")
      ExBanking.deposit("test5", 5, "INR")
      response = ExBanking.withdraw("test5", 15.00, "INR")

      assert {:error, :not_enough_money} == response
    end

    test "failed to withdraw money -> currency is not valid" do
      ExBanking.create_user("test6")
      response = ExBanking.withdraw("test6", 15.00, "INr")

      assert {:error, :wrong_arguments} == response
    end

    test "failed to withdraw money - when user not exist" do
      response = ExBanking.withdraw("Foo", 15.00, "INr")

      assert {:error, :user_does_not_exist} == response
    end
  end

  describe "send/4" do
    test "success" do
      ExBanking.create_user("test7")
      ExBanking.create_user("test8")
      amount = 10.00
      {:ok, sender_balance} = ExBanking.deposit("test7", amount, "INR")

      {:ok, sender_new_balance, receiver_new_balance} =
        ExBanking.send("test7", "test8", amount, "INR")

      assert sender_new_balance == sender_balance - amount
      assert receiver_new_balance == amount
    end

    test "failure - sender does not exists" do
      assert {:error, :sender_does_not_exist} == ExBanking.send("test33", "test4", 10.00, "INR")
    end

    test "failure - receiver does not exists" do
      ExBanking.create_user("test9")
      assert {:error, :receiver_does_not_exist} == ExBanking.send("test9", "test44", 100, "INR")
    end

    test "failure - sender insufficient balance" do
      ExBanking.create_user("test10")
      ExBanking.create_user("test11")
      ExBanking.deposit("test10", 10, "INR")

      assert {:error, :not_enough_money} ==
               ExBanking.send("test10", "test11", 20, "INR")
    end

    test "failure - wrong arguments" do
      ExBanking.create_user("test12")
      ExBanking.create_user("test13")
      assert {:error, :wrong_arguments} == ExBanking.send("test12", "test13", -10.00, "INR")
    end
  end
end
