defmodule Authorizer do
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
        IO.puts("All transactions processed")
        System.halt(0)

      {:error, reason} ->
        IO.puts("Error! Reason: #{reason}")
        System.halt(1)

      line ->
        {:ok, _, new_state} =
          line
          |> JsonHandler.to_struct!()
          |> make_me_solid(state)

        OperationPrinter.print(new_state.account)

        Authorizer.main([new_state])
    end
  end

  defp make_me_solid(%Account{} = type, state) do
    Account.create(type.card_active, type.available_limit, state)
  end

  defp make_me_solid(%Transaction{} = type, state) do
    Transaction.apply(type.merchant, type.amount, type.time, state)
  end
end
