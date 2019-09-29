# lib/infrastructure/printer/operation_printer.ex
defmodule Authorizer.Infrastructure.OperationPrinterTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias Authorizer.Infrastructure.OperationPrinter
  alias Authorizer.{Account, Transaction}

  doctest OperationPrinter

  describe "print/1" do
    test "print an account to stdout" do
      account = %Account{card_active: true, available_limit: 250, violations: []}

      expected_output =
        "{\"account\":{\"violations\":[],\"card_active\":true,\"available_limit\":250}}\n"

      stdout = capture_io(fn -> OperationPrinter.print(account) end)

      assert stdout == expected_output
    end

    test "print a transaction to stdout" do
      transaction = %Transaction{
        merchant: "Habbib's",
        amount: 90,
        time: ~U[2019-02-13T11:00:00.000Z]
      }

      expected_output =
        "{\"transaction\":{\"time\":\"2019-02-13T11:00:00.000Z\",\"merchant\":\"Habbib's\",\"amount\":90}}\n"

      stdout = capture_io(fn -> OperationPrinter.print(transaction) end)

      assert stdout == expected_output
    end
  end
end
