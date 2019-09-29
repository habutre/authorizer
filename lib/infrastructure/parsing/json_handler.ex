# lib/infrastructure/parsing/json_handler.ex
defmodule Authorizer.Infrastructure.JsonHandler do
  alias Authorizer.{Account, Transaction}

  @moduledoc """
  JsonParser translates the expected input stream into
  well-known structs like Account and Transaction
  """

  def to_struct!(payload) do
    payload
    |> Poison.decode!()
    |> discover_input_type()
    |> build()
  end

  def to_json(type) when is_map(type) do
    Poison.encode!(identify_operation(type))
  end

  def to_json(type) do
    Poison.encode!(type)
  end

  defp discover_input_type(value) do
    type = value |> Map.keys() |> List.first()

    [type, value]
  end

  defp build([type, content] = _value) do
    build(type, content)
  end

  defp build("account" = type, value) do
    body = Map.get(value, type)

    %Account{card_active: body["activeCard"], available_limit: body["availableLimit"]}
  end

  defp build("transaction" = type, value) do
    body = Map.get(value, type)
    {:ok, time, 0} = DateTime.from_iso8601(body["time"])

    %Transaction{merchant: body["merchant"], amount: body["amount"], time: time}
  end

  defp build(_type, _value) do
    %{}
  end

  defp identify_operation(type) do
    operation_name =
      if Map.has_key?(type, :__struct__) do
        type.__struct__
        |> Atom.to_string()
        |> String.split(".")
        |> List.last()
        |> String.downcase()
      else
        "unknown"
      end

    %{operation_name => type}
  end
end
