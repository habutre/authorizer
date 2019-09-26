defmodule Authorizer.AccountTest do
  use ExUnit.Case
  alias Authorizer.Account
  doctest Account

  describe "create/2" do
    test "creates and initialize an account with active card and limit of 120" do
      output = Account.create(true, 120)

      assert true == output.card_active
      assert 120 == output.available_limit
      assert Enum.empty?(output.violations)
    end

    test "creates and initialize an account with inactive card and limit of 120" do
      output = Account.create(false, 120)

      assert false == output.card_active
      assert 120 == output.available_limit
      assert Enum.empty?(output.violations)
    end

    test "fail to create and initialize an existent account" do
      account = Account.create(true, 120)
      output = Account.create(true, 120, account)

      assert true == output.card_active
      assert 120 == output.available_limit
      refute Enum.empty?(output.violations)

      [h | _] = output.violations
      assert h == "account-already-initialized"
    end
  end
end
