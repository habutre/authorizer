defmodule Authorizer do
  require Logger
  alias Authorizer.{Account, Transaction}
  alias Authorizer.Infrastructure.{JsonHandler, OperationPrinter}

  defstruct [:account, :transactions]

  @type t :: %__MODULE__{account: Account.t(), transactions: list(Transaction.t())}

  @moduledoc """
  Authorizer is an application responsible by create accounts
  and process transactions.
  The main rule for the Authorizer is validate if a transaction
  can be successfully processed based on remaining limit balance
  """

  @doc """
  Main function responsible to be the entrypoint of App
  """
  def main(args \\ []) do
    state = List.first(args) || %{}

    case IO.read(:stdio, :line) do
      :eof ->
        Logger.debug("All transactions processed")
        System.halt(0)

      {:error, reason} ->
        Logger.error("Error! Reason: #{reason}")
        System.halt(1)

      line ->
        line
        |> JsonHandler.to_struct!()
        |> process_authorization(state)
        |> OperationPrinter.print()
        # recursively call main passing the state as List
        |> (&Authorizer.main([&1])).()
    end
  end

  defp process_authorization(%Account{} = type, state) do
    Logger.debug("Processing Account")
    Account.create(type.card_active, type.available_limit, state)
  end

  defp process_authorization(%Transaction{} = type, state) do
    Logger.debug("Processing Transaction")
    Transaction.apply(type.merchant, type.amount, type.time, state)
  end
end
