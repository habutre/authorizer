defmodule Authorizer.TransactionTest do
  use ExUnit.Case

  alias Authorizer.{Account, Transaction}

  doctest Transaction

  describe "apply/4" do
    test "process a transaction deducting the amount from account limit" do
      account = %Account{card_active: true, available_limit: 80, violations: []}

      transaction = %Transaction{
        merchant: "Monsters Inc.",
        amount: 20,
        time: ~U[2019-09-09T09:38:04Z]
      }

      state = %{account: account, transactions: [transaction]}

      {:ok, deducted_account, _state} =
        Transaction.apply("Acme Inc.", 35, ~U[2019-09-10T17:55:21Z], state)

      assert true == deducted_account.card_active
      assert 45 == deducted_account.available_limit
      assert [] == deducted_account.violations
    end

    test "fail to process a transaction due insufficient-limit" do
      account = %Account{card_active: true, available_limit: 40, violations: []}

      transaction = %Transaction{
        merchant: "Monsters Inc.",
        amount: 20,
        time: ~U[2019-09-09T09:38:04Z]
      }

      state = %{account: account, transactions: [transaction]}

      {:ok, violated_account, _state} =
        Transaction.apply("Acme Inc.", 65, ~U[2019-09-10T17:55:21Z], state)

      assert true == violated_account.card_active
      assert 40 == violated_account.available_limit
      refute Enum.empty?(violated_account.violations)

      [h | _] = violated_account.violations
      assert h == "insufficient-limit"
    end

    test "fail to process a transaction when the card is NOT active" do
      account = %Account{card_active: false, available_limit: 130, violations: []}

      transaction = %Transaction{
        merchant: "Monsters Inc.",
        amount: 20,
        time: ~U[2019-09-09T09:38:04Z]
      }

      state = %{account: account, transactions: [transaction]}

      {:ok, violated_account, _state} =
        Transaction.apply("Acme Inc.", 65, ~U[2019-09-10T17:55:21Z], state)

      assert false == violated_account.card_active
      assert 130 == violated_account.available_limit
      refute Enum.empty?(violated_account.violations)

      [h | _] = violated_account.violations
      assert h == "card-not-active"
    end

    test "fail to process a transaction when +3 transactions are processed within 2min time range" do
      account = %Account{card_active: true, available_limit: 110, violations: []}

      transaction1 = %Transaction{
        merchant: "Monsters Inc.",
        amount: 20,
        time: ~U[2019-09-09T18:38:04Z]
      }

      transaction2 = %Transaction{
        merchant: "Acme Inc.",
        amount: 30,
        time: ~U[2019-09-09T18:39:48Z]
      }

      state = %{account: account, transactions: [transaction1, transaction2]}

      {:ok, violated_account, _state} =
        Transaction.apply("Acme Inc.", 65, ~U[2019-09-09T18:40:12Z], state)

      assert true == violated_account.card_active
      assert 110 == violated_account.available_limit
      refute Enum.empty?(violated_account.violations)

      last_violation = List.last(violated_account.violations)
      assert last_violation == "high-frequency-small-interval"
    end

    test "process a transaction deducting amount when time between transactions is >2min" do
      account = %Account{card_active: true, available_limit: 110, violations: []}

      transaction1 = %Transaction{
        merchant: "Monsters Inc.",
        amount: 20,
        time: ~U[2019-09-09T18:28:04Z]
      }

      transaction2 = %Transaction{
        merchant: "Acme Inc.",
        amount: 30,
        time: ~U[2019-09-09T18:39:48Z]
      }

      state = %{account: account, transactions: [transaction1, transaction2]}

      {:ok, violated_account, _state} =
        Transaction.apply("Acme Inc.", 65, ~U[2019-09-09T18:40:12Z], state)

      assert true == violated_account.card_active
      assert 45 == violated_account.available_limit
      assert Enum.empty?(violated_account.violations)
    end

    test "process a transaction that looks similar but with different amounts" do
      account = %Account{card_active: true, available_limit: 110, violations: []}

      transaction1 = %Transaction{
        merchant: "Monsters Inc.",
        amount: 20,
        time: ~U[2019-09-09T18:28:04Z]
      }

      state = %{account: account, transactions: [transaction1]}

      {:ok, deducted_account, _state} =
        Transaction.apply("Monsters Inc.", 65, ~U[2019-09-09T19:30:03Z], state)

      assert true == deducted_account.card_active
      assert 45 == deducted_account.available_limit
      assert Enum.empty?(deducted_account.violations)
    end

    test "fail to process a similar transaction" do
      account = %Account{card_active: true, available_limit: 110, violations: []}

      transaction1 = %Transaction{
        merchant: "Monsters Inc.",
        amount: 20,
        time: ~U[2019-09-09T18:28:04Z]
      }

      state = %{account: account, transactions: [transaction1]}

      {:ok, violated_account, _state} =
        Transaction.apply("Monsters Inc.", 20, ~U[2019-09-09T19:30:03Z], state)

      assert true == violated_account.card_active
      assert 110 == violated_account.available_limit
      refute Enum.empty?(violated_account.violations)

      [violation | _] = violated_account.violations
      assert violation == "doubled-transaction"
    end
  end
end
