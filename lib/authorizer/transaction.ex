defmodule Authorizer.Transaction do
  alias Authorizer.{Account, Transaction}

  alias Authorizer.Transaction.{
    ActiveCardValidator,
    DuplicationValidator,
    HighFrequencyValidator,
    LimitValidator
  }

  defstruct [:merchant, :amount, :time]

  @moduledoc """
  Transaction is a module responsible by process transactions
  """

  @type t :: %Transaction{
          merchant: String.t(),
          amount: integer(),
          time: DateTime.t()
        }

  @doc """
  Process a transaction with informed merchant, amount and time

  ## Example
      iex> account = %Account{card_active: true, available_limit: 120, violations: []}
      iex> Transaction.apply("Acme Inc.", 35, ~U[2019-09-10T14:32:56Z], %{account: account, transactions: []})
      {:ok, %Account{card_active: true, available_limit: 85, violations: []}, %{account: %Account{card_active: true, available_limit: 85, violations: []}, transactions: [%Transaction{merchant: "Acme Inc.", amount: 35, time: ~U[2019-09-10T14:32:56Z]}]}}
  """
  @spec apply(String.t(), integer(), DateTime.t(), %{account: Account.t(), transactions: list()}) ::
          {:ok, Account.t(), %{account: Account.t(), transactions: list()}}
  def apply(merchant, amount, time, state) do
    {_, new_state} =
      with(
        {:ok, valid_state} <- ActiveCardValidator.validate(merchant, amount, time, state),
        {:ok, valid_state} <- LimitValidator.validate(merchant, amount, time, valid_state),
        {:ok, valid_state} <- DuplicationValidator.validate(merchant, amount, time, valid_state),
        {:ok, valid_state} <- HighFrequencyValidator.validate(merchant, amount, time, valid_state)
      ) do
        %{account: account, transactions: transactions} = valid_state
        remaining = account.available_limit - amount
        deducted_account = %{account | available_limit: remaining}
        transaction = %Transaction{merchant: merchant, amount: amount, time: time}
        deducted_state = %{account: deducted_account, transactions: [transaction | transactions]}

        {:ok, deducted_state}
      end

    %{account: account, transactions: _transactions} = new_state

    {:ok, account, new_state}
  end
end
