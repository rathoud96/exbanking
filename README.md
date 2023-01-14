# ExBanking

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_banking` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_banking, "~> 0.1.0"}
  ]
end
```

## How to run

open iex console by running `iex -S mix`

```elixir
# Create User
ExBanking.create_user("username")

# Deposit money
ExBanking.deposit("username", 100,  "INR")

# Withdraw money
ExBanking.withdraw("username", 100, "INR")

# Send money
ExBanking.send(from_user, to_user, 100, "INR")
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_banking](https://hexdocs.pm/ex_banking).

