defmodule Authorizer.Transaction do
  alias __MODULE__
  alias Authorizer.Account
  defstruct [:merchant, :amount, :time]

  @moduledoc """
  Transaction is a module responsible by process transactions
  """

  @type t :: %__MODULE__{
          merchant: String.t(),
          amount: integer(),
          time: DateTime.t()
        }

  @doc """
  Process a transaction with informed merchant, amount and time

  ## Example
      iex> account = %Account{card_active: true, available_limit: 120, violations: []}
      iex> Transaction.apply("Acme Inc.", 35, "2019-09-10T14:32:56Z", %{account: account, transactions: []})
      %Account{card_active: true, available_limit: 85, violations: []}
  """
  @spec apply(String.t(), integer(), DateTime.t(), %{account: Account.t(), transactions: list()}) ::
          Account.t()
  def apply(merchant, amount, time, state) do
    %{account: account, transactions: transactions} = state

    # TODO Open/Close principle, new rules will be added in future releases, so...
    cond do
      !account.card_active ->
        %{account | violations: ["card-not-active" | account.violations]}

      account.available_limit < amount ->
        %{account | violations: ["insufficient-limit" | account.violations]}

      high_frequency_transactions?(transactions, time, 0) ->
        %{account | violations: ["high-frequency-small-interval" | account.violations]}

      duplication_detected?(transactions, merchant, amount, time) ->
        %{account | violations: ["doubled-transaction" | account.violations]}

      true ->
        remaining = account.available_limit - amount

        %{account | available_limit: remaining}
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

  defp duplication_detected?([] = _transactions, _merchant, _amount, _time), do: false

  defp duplication_detected?(transactions, _merchant, _amount, _time) when is_nil(transactions),
    do: false

  defp duplication_detected?(transactions, merchant, amount, time) do
    # candidates =
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

    # if is_nil(candidates) do
    #  false
    # else
    #  candidates
    #  |> Enum.reduce(0, fn candidate_amount, acc -> if candidate_amount == amount, do: acc+1, else: acc end)
    #  |> (&(&1>=1)).()
    # end
  end

  defp within_range?(pivot, transaction_time) do
    dupl_time_range = DateTime.add(pivot, -120)
    comparison = DateTime.compare(dupl_time_range, transaction_time)

    if comparison == :lt, do: false, else: true
  end
end
