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
      {:ok, %Account{card_active: true, available_limit: 120, violations: []}, %{account: %Account{card_active: true, available_limit: 120, violations: []}, transactions: []}}
  """
  @spec create(boolean(), integer()) ::
          {:ok, Account.t(), %{account: Account.t(), transactions: list()}}
  def create(card_status, limit) do
    account = %Account{card_active: card_status, available_limit: limit, violations: []}

    {:ok, account, %{account: account, transactions: []}}
  end

  @doc """
  See `Authorizer.Account.create/3`
  """
  def create(card_status, limit, state) when map_size(state) == 0 do
    account = %Account{card_active: card_status, available_limit: limit, violations: []}

    {:ok, account, %{account: account, transactions: []}}
  end

  @doc """
  Do not create an account with informed card status and available limit
  instead return the existent account with specific violation

  ## Example
      iex> Account.create(true, 850, %{account: %Account{card_active: true, available_limit: 120}, transactions: []})
      {:ok, %Account{card_active: true, available_limit: 120, violations: ["account-already-initialized"|nil]}, %{account: %Account{card_active: true, available_limit: 120, violations: ["account-already-initialized"|nil]}, transactions: []}}
  """
  @spec create(boolean(), integer(), %{account: Account.t(), transactions: list()}) ::
          {:ok, Account.t(), %{account: Account.t(), transactions: list()}}
  def create(_card_status, _limit, state) do
    %{account: account, transactions: transactions} = state

    new_account = %{account | violations: ["account-already-initialized" | account.violations]}

    {:ok, new_account, %{account: new_account, transactions: transactions}}
  end
end
