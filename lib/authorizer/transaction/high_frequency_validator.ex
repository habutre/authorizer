# lib/authorizer/transaction/high_frequency_validator.ex
defmodule Authorizer.Transaction.HighFrequencyValidator do
  alias Authorizer.Account

  @behaviour Authorizer.Transaction.Validator

  @moduledoc """
  Validates if there is subsequente transactions in a short period of time for a given account
  """

  @spec validate(
          String.t(),
          integer(),
          DateTime.t(),
          %{account: Account.t(), transactions: list()}
        ) ::
          {:ok, %{account: Account.t(), transactions: list()}}
          | {:error, %{account: Account.t(), transactions: list()}}
  def validate(_merchant, _amount, time, state) do
    %{account: account, transactions: transactions} = state

    if high_frequency_transactions?(transactions, time, 0) do
      violated_account = %{
        account
        | violations: ["high-frequency-small-interval" | account.violations]
      }

      new_state = %{account: violated_account, transactions: transactions}

      {:error, new_state}
    else
      {:ok, state}
    end
  end

  # private funcs

  defp high_frequency_transactions?([] = _transactions, _time, _acc), do: false

  defp high_frequency_transactions?(transactions, _time, _acc) when is_nil(transactions),
    do: false

  defp high_frequency_transactions?(transactions, _time, acc)
       when length(transactions) < 2 and acc == 0,
       do: false

  defp high_frequency_transactions?(transactions, time, acc) do
    [first | remaining] = transactions
    next = List.first(remaining)

    cond do
      Enum.empty?(remaining) ->
        seconds_between_transactions = abs(Time.diff(first.time, time))
        if seconds_between_transactions + acc >= 120, do: true, else: false

      abs(Time.diff(first.time, next.time)) > 120 ->
        # diff between transactions is bigger than expected interval
        false

      acc < 120 ->
        seconds_between_transactions = abs(Time.diff(first.time, next.time))
        high_frequency_transactions?(remaining, time, acc + seconds_between_transactions)

      true ->
        # no issues found
        false
    end
  end
end
