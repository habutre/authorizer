# test/infrastructure/parsing/json_handler_test.ex
defmodule JsonHandlerTest do
  use ExUnit.Case
  alias Authorizer.{Account, Transaction}
  alias Authorizer.Infrastructure.JsonHandler

  describe "to_struct!/1" do
    test "translate an account from input stream" do
      payload = "{\"account\": { \"activeCard\": true, \"availableLimit\": 100}}"
      expected_account = %Account{card_active: true, available_limit: 100}

      account = JsonHandler.to_struct!(payload)

      assert expected_account == account
    end

    test "translate a transaction from input stream" do
      payload =
        "{\"transaction\": { \"merchant\": \"Habbib's\", \"amount\": 90, \"time\": \"2019-02-13T11:00:00.000Z\"}}"

      expected_transaction = %Transaction{
        merchant: "Habbib's",
        amount: 90,
        time: ~U[2019-02-13T11:00:00.000Z]
      }

      transaction = JsonHandler.to_struct!(payload)

      assert expected_transaction == transaction
    end

    test "fail to decode from unknown input stream type" do
      payload = "{\"notification\": { \"msg\": \"doesn't matter\"}}"
      expected_account = %{}

      account = JsonHandler.to_struct!(payload)

      assert expected_account == account
    end
  end

  describe "to_json/1" do
    test "convert an account" do
      account = %Account{card_active: true, available_limit: 250, violations: []}

      expected_json =
        "{\"account\":{\"violations\":[],\"card_active\":true,\"available_limit\":250}}"

      json = JsonHandler.to_json(account)

      assert expected_json == json
    end

    test "convert a transaction" do
      transaction = %Transaction{
        merchant: "Acme Inc.",
        amount: 276,
        time: ~U[2019-09-11T08:37:42Z]
      }

      expected_json =
        "{\"transaction\":{\"time\":\"2019-09-11T08:37:42Z\",\"merchant\":\"Acme Inc.\",\"amount\":276}}"

      json = JsonHandler.to_json(transaction)

      assert expected_json == json
    end

    test "convert an unknow type" do
      unknown = %{name: "The unknown type"}
      expected_json = "{\"unknown\":{\"name\":\"The unknown type\"}}"

      json = JsonHandler.to_json(unknown)

      assert expected_json == json
    end

    test "convert a non-map struct" do
      non_map = ["a", "b", "c"]
      expected_json = "[\"a\",\"b\",\"c\"]"

      json = JsonHandler.to_json(non_map)

      assert expected_json == json
    end
  end
end
