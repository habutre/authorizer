# lib/authorizer/transaction/limit_validator.ex
defmodule Authorizer.Transaction.LimitValidator do
  alias Authorizer.Account

  @behaviour Authorizer.Transaction.Validator

  @moduledoc """
  Validates if the account limit was not reached in the moment of transaction be processed
  """

  @spec validate(
          String.t(),
          integer(),
          DateTime.t(),
          %{account: Account.t(), transactions: list()}
        ) ::
          {:ok, %{account: Account.t(), transactions: list()}}
          | {:error, %{account: Account.t(), transactions: list()}}
  def validate(_merchant, amount, _time, state) do
    %{account: account, transactions: transactions} = state

    if account.available_limit < amount do
      violated_account = %{account | violations: ["insufficient-limit" | account.violations]}
      new_state = %{account: violated_account, transactions: transactions}

      {:error, new_state}
    else
      {:ok, state}
    end
  end
end
