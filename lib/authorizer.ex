defmodule Authorizer do
  @moduledoc """
  Authorizer is an application responsible by create accounts
  and process transactions.
  The main rule for the Authorizer is validate if a transaction
  can be successfully processed based on remaining limit balance
  """

  @doc """
  Main function responsible to be the entrypoint of App
  """
  def main(_args) do
    case IO.read(:stdio, :line) do
      :eof ->
        IO.puts("All transactions processed")

      {:error, reason} ->
        IO.puts("Error! Reason: #{reason}")

      line ->
        IO.puts(String.replace(line, ~r/[\n\r\t]+/, "", global: true))
        Authorizer.main(nil)
    end

    System.halt(0)
  end
end
