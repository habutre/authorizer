defmodule Authorizer.AccountTest do
  use ExUnit.Case

  alias Authorizer.Account

  doctest Account

  describe "create/2" do
    test "creates and initialize an account with active card and limit of 120" do
      {:ok, account, %{account: account, transactions: _transactions}} = Account.create(true, 120)

      assert true == account.card_active
      assert 120 == account.available_limit
      assert Enum.empty?(account.violations)
    end

    test "creates and initialize an account with inactive card and limit of 120" do
      {:ok, account, %{account: account, transactions: _transactions}} =
        Account.create(false, 120)

      assert false == account.card_active
      assert 120 == account.available_limit
      assert Enum.empty?(account.violations)
    end

    test "fail to create and initialize an existent account" do
      {:ok, _account1, state1} = Account.create(true, 120)
      {:ok, account2, _state2} = Account.create(true, 120, state1)

      assert true == account2.card_active
      assert 120 == account2.available_limit
      refute Enum.empty?(account2.violations)

      [h | _] = account2.violations
      assert h == "account-already-initialized"
    end
  end
end
