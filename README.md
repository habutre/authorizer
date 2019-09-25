# Authorizer

In order to validate the Authorizer App execution three possible ways are proposed

The first two proposed ways needs some installed dependencies
* Elixir 1.9
* Erlang 22
* Use the ex_doc to see the documentation locally (details on `shipping.sh:5`)

## Running the code locally

1. Extract the code and execute `cd authorize`
1. Execute the following commands (commands will work on *nix systems*)
    1. cd authorizer
    1. mix deps.get
    1. mix deps.compile
    1. iex -S mix
    1. Authorizer.main(nil)
    1. {"input": "your-input-line-as-json-here"}

As a result one should see an output like this:

```
{ "account": { "activeCard": true, "availableLimit": 100 }, "violations": [] }
```

> Follow the instruction on `shipping.sh:5` for generate and check documentation

## Running with code locally assembled

1. Extract the code and execute `cd authorize`
1. Execute the following commands (commands will work on *nix systems*)
    1. cd authorizer
    1. mix deps.get
    1. mix deps.compile
    1. mix escript.build
    1. ./authorizer < filename

As a result one should see an output like this:

```
{ "account": { "activeCard": true, "availableLimit": 100 }, "violations": [] }
```

> Follow the instruction on `shipping.sh:5` for generate and check documentation

## Running via docker

1. Execute the following commands (commands will work on *nix systems*)
    1. Extract the code and execute `cd authorize`
    1. ./shipping.sh 
    1. docker run -ti -p 80:80 company/authorizer:0.1.0 < filename
    1. Check the output for validation
    1. Open the link in your browser (http://localhost/Authorizer.html)

As a result one should see an output like this:

```
Executing Authorizer app
|Posição Chegada|Código Piloto|Nome Piloto    |Qtde Voltas Completadas|Tempo Total de Prova|Melhor Volta|Média Velocidade|
|              1|          038|F.MASSA        |                      4|     00:04:11.578000|00:01:02.769|          18.446|
|              2|          002|K.RAIKKONEN    |                      4|     00:04:15.153000|00:01:03.076|          18.275|
|              3|          033|R.BARRICHELLO  |                      4|     00:04:16.080000|00:01:03.716|          18.122|
|              4|          023|M.WEBBER       |                      4|     00:04:17.722000|00:01:04.216|          18.030|
|              5|          015|F.ALONSO       |                      4|     00:04:54.221000|00:01:07.011|          15.274|
|              6|          011|S.VETTEL       |                      3|     00:06:27.276000|00:01:18.097|          18.812|
Go to http://localhost/Authorizer.html to check the project documentation
```

> The nginx logs will be printed in the current terminal, so ensure to validate the output or run the docker steps again


**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `authorizer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:authorizer, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/authorizer](https://hexdocs.pm/authorizer).

