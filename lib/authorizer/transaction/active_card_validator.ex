# lib/authorizer/transaction/active_card_validator.ex
defmodule Authorizer.Transaction.ActiveCardValidator do
  alias Authorizer.Account

  @behaviour Authorizer.Transaction.Validator

  @moduledoc """
  Validates the status of card to ensure a transaction can be processed
  """

  @spec validate(
          String.t(),
          integer(),
          DateTime.t(),
          %{account: Account.t(), transactions: list()}
        ) ::
          {:ok, %{account: Account.t(), transactions: list()}}
          | {:error, %{account: Account.t(), transactions: list()}}
  def validate(_merchant, _amount, _time, state) do
    %{account: account, transactions: transactions} = state

    if account.card_active do
      {:ok, state}
    else
      violated_account = %{account | violations: ["card-not-active" | account.violations]}
      new_state = %{account: violated_account, transactions: transactions}

      {:error, new_state}
    end
  end
end
