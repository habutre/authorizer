# test/infrastructure/parsing/json_parser_test.ex
defmodule JsonParserTest do
  use ExUnit.Case
  alias Authorizer.{Account, Transaction}
  alias Authorizer.Infrastructure.JsonParser

  describe "translate_type/1" do
    test "translate an account from input stream" do
      payload = "{\"account\": { \"activeCard\": true, \"availableLimit\": 100}}"
      expected_account = %Account{card_active: true, available_limit: 100}

      account = JsonParser.translate_type!(payload)

      assert expected_account == account
    end

    test "translate a transaction from input stream" do
      payload = "{\"transaction\": { \"merchant\": \"Habbib's\", \"amount\": 90, \"time\": \"2019-02-13T11:00:00.000Z\"}}"
      expected_transaction = %Transaction{merchant: "Habbib's", amount: 90, time: ~U[2019-02-13T11:00:00.000Z]}

      transaction = JsonParser.translate_type!(payload)

      assert expected_transaction == transaction
    end

    test "fail to decode from unknown input stream type" do
      payload = "{\"notification\": { \"msg\": \"doesn't matter\"}}"
      expected_account = %{}

      account = JsonParser.translate_type!(payload)

      assert expected_account == account
    end
  end
end
