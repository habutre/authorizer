# lib/authorizer/transaction/validator.ex
defmodule Authorizer.Transaction.Validator do
  alias Authorizer.Account

  @moduledoc """
  Interface for transaction validation rules
  """

  @callback validate(
              String.t(),
              integer(),
              DateTime.t(),
              %{account: Account.t(), transactions: list()}
            ) ::
              {:ok, %{account: Account.t(), transactions: list()}}
              | {:error, %{account: Account.t(), transactions: list()}}
end
