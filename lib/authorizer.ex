defmodule Authorizer do
  @moduledoc """
  Documentation for Authorizer.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Authorizer.hello()
      :world

  """
  def hello do
    :world
  end

  @doc """
    Main function responsible to be the entrypoint of App
  """
  def main(_args) do
    case IO.read(:stdio, :line) do
      :eof ->
        IO.puts "All transactions processed"
      {:error, reason} ->
        IO.puts "Error! Reason: #{reason}"
      line ->
        IO.puts String.replace(line, ~r/[\n\r\t]+/, "", global: true)
        Authorizer.main(nil)
    end

    System.halt(0)
  end
end
