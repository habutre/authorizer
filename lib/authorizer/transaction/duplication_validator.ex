# lib/authorizer/transaction/duplication_validator.ex
defmodule Authorizer.Transaction.DuplicationValidator do
  alias Authorizer.Account

  @behaviour Authorizer.Transaction.Validator

  @moduledoc """
  Validates if there is multiple similar transactions in a short period of time
  """

  @spec validate(
          String.t(),
          integer(),
          DateTime.t(),
          %{account: Account.t(), transactions: list()}
        ) ::
          {:ok, %{account: Account.t(), transactions: list()}}
          | {:error, %{account: Account.t(), transactions: list()}}
  def validate(merchant, amount, time, state) do
    %{account: account, transactions: transactions} = state

    if duplication_detected?(transactions, merchant, amount, time) do
      violated_account = %{account | violations: ["doubled-transaction" | account.violations]}
      new_state = %{account: violated_account, transactions: transactions}

      {:error, new_state}
    else
      {:ok, state}
    end
  end

  # private funcs

  defp duplication_detected?([] = _transactions, _merchant, _amount, _time), do: false

  defp duplication_detected?(transactions, _merchant, _amount, _time) when is_nil(transactions),
    do: false

  defp duplication_detected?(transactions, merchant, amount, time) do
    transactions
    |> Enum.filter(fn transaction -> transaction.merchant == merchant end)
    |> Enum.filter(fn transaction -> within_range?(time, transaction.time) end)
    |> Enum.group_by(fn transaction -> transaction.merchant end, fn transaction ->
      transaction.amount
    end)
    |> Map.get(merchant, [])
    |> Enum.reduce(0, fn candidate_amount, acc ->
      if candidate_amount == amount, do: acc + 1, else: acc
    end)
    |> (&(&1 >= 1)).()
  end

  defp within_range?(pivot, transaction_time) do
    dupl_time_range = DateTime.add(pivot, -120)
    comparison = DateTime.compare(dupl_time_range, transaction_time)

    if comparison == :lt, do: false, else: true
  end
end
