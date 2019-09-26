defmodule Authorizer.Account do
  alias __MODULE__
  defstruct [:card_active, :available_limit, :violations]

  @moduledoc """
  Account is a module responsible by create accounts ensuring
  there is no duplications
  """

  @type t :: %__MODULE__{
          card_active: boolean(),
          available_limit: integer(),
          violations: list()
        }

  @doc """
  Creates an account with informed card status and available limit

  ## Example
      iex> Account.create(true, 120)
      %Account{card_active: true, available_limit: 120, violations: []}
  """
  @spec create(boolean(), integer()) :: __MODULE__.t()
  def create(card_status, limit) do
    %Account{card_active: card_status, available_limit: limit, violations: []}
  end

  @doc """
  See `Authorizer.Account.create/3`
  """
  def create(card_status, limit, account) when is_nil(account) do
    %Account{card_active: card_status, available_limit: limit, violations: []}
  end

  @doc """
  Do not create an account with informed card status and available limit
  instead return the existent account with specific violation

  ## Example
      iex> Account.create(true, 850, %Account{card_active: true, available_limit: 120})
      %Account{card_active: true, available_limit: 120, violations: ["account-already-initialized"]}
  """
  @spec create(boolean(), integer(), __MODULE__.t()) :: __MODULE__.t()
  def create(_card_status, _limit, account) do
    %Account{
      card_active: account.card_active,
      available_limit: account.available_limit,
      violations: ["account-already-initialized"]
    }
  end
end
