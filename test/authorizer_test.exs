defmodule AuthorizerTest do
  use ExUnit.Case

  doctest Authorizer

  describe "main/0" do
    test "process the account from stdin" do
      input = "{\"account\": {\"activeCard\": true, \"availableLimit\": 250}}"

      expected_output =
        "{\"account\":{\"violations\":[],\"card_active\":true,\"available_limit\":250}}\n"

      assert input, "Not implemented yet"
      assert expected_output, "Not implemented yet"
    end
  end

  describe "main/1" do
  end
end
