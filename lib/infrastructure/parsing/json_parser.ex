# lib/infrastructure/parsing/json_parser.ex
defmodule Authorizer.Infrastructure.JsonParser do
  alias Authorizer.{Account, Transaction}

  def translate_type!(payload) do
    payload
    |> Poison.decode!()
    |> discover_input_type()
    |> build()
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
end
