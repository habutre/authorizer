# lib/infrastructure/printer/operation_printer.ex
defmodule Authorizer.Infrastructure.OperationPrinter do
  alias Authorizer.Infrastructure.JsonHandler

  @moduledoc """
  OperationPrinter take a type, filter null values and
  output as string to stdout
  """

  def print(value) do
    {:ok, _, state} = value

    state.account
    |> filter_nils()
    |> JsonHandler.to_json()
    |> IO.puts()

    state
  end

  defp filter_nils(value) when is_map(value) do
    value
    |> Map.to_list()
    |> Enum.filter(fn {_k, v} -> !is_nil(v) end)
    |> Enum.into(%{})
  end

  defp filter_nils(value) when is_list(value) do
    Enum.filter(value, fn item -> !is_nil(item) end)
  end

  defp filter_nils(value), do: value
end
