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
  def main(state \\ %Authorizer{}) do
    case IO.read(:stdio, :line) do
      :eof ->
        IO.puts("All transactions processed")
        System.halt(0)

      {:error, reason} ->
        IO.puts("Error! Reason: #{reason}")
        System.halt(1)

      line ->
        line
        |> JsonHandler.to_struct!()
        |> OperationPrinter.print()

        # IO.puts(String.replace(line, ~r/[\n\r\t]+/, "", global: true))
        Authorizer.main(%Authorizer{})
    end
  end
end
