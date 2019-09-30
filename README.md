# Authorizer

In order to validate the Authorizer App execution three possible ways are proposed

The first three proposed ways needs some installed dependencies
* Elixir 1.9
* Erlang 22
* mix local.hex
* mix escript.install hex ex_doc
* Use the ex_doc to see the documentation locally (details on `shipping.sh:5`)

## Running the code locally

1. Extract the code and execute `cd authorize`
1. Execute the following commands (commands will work on *nix systems*)
    1. cd authorizer
    1. mix deps.get
    1. mix deps.compile
    1. iex -S mix
    1. Authorizer.main(nil)
    1. {"account": {"activeCard": true, "availableLimit": 100}}

As a result one should see an output similar to:

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
    1. ./authorizer < filename # assuming the content is the same as previous step

As a result one should see an output similar to:

```
{ "account": { "activeCard": true, "availableLimit": 100 }, "violations": [] }
```

> Follow the instruction on `shipping.sh:5` for generate and check documentation

## Running via docker (Elixir environment provided)

1. Execute the following commands (commands will work on *nix systems*)
    1. Extract the code and execute `cd authorize`
    1. ./shipping.sh 
    1. cat filename | docker run -i -p 80:80 company/authorizer:0.1.0
    1. Check the output for validation
    1. Open the link in your browser (http://localhost/Authorizer.html)

With an input provided in the project `stream.txt` as well as on challenge description (pdf):

```
⇒ cat stream.txt
{"account": { "activeCard": true, "availableLimit": 100 } }
{"transaction": { "merchant": "Burger King", "amount": 20, "time": "2019-02-13T10:00:00.000Z" } }
{"transaction": { "merchant": "Habbib's", "amount": 90, "time": "2019-02-13T11:00:00.000Z" } }
```

One should see a output like this:

```
{"account": { "activeCard": true, "availableLimit": 100 } }
{"transaction": { "merchant": "Burger King", "amount": 20, "time": "2019-02-13T10:00:00.000Z" } }
{"transaction": { "merchant": "Habbib's", "amount": 90, "time": "2019-02-13T11:00:00.000Z" } }
```

## Running via docker only (No Elixir environment needed)

1. Execute the following commands (commands will work on *nix systems*)
    1. Extract the code and execute `cd authorize`
    1. ./shipping-multi-stage.sh 
    1. cat filename | docker run -i -p 80:80 company/authorizer:0.1.0
    1. Check the output for validation
    1. Open the link in your browser (http://localhost/Authorizer.html)

With an input provided in the project `stream.txt` as well as on challenge description (pdf):

```
⇒ cat stream.txt
{"account": { "activeCard": true, "availableLimit": 100 } }
{"transaction": { "merchant": "Burger King", "amount": 20, "time": "2019-02-13T10:00:00.000Z" } }
{"transaction": { "merchant": "Habbib's", "amount": 90, "time": "2019-02-13T11:00:00.000Z" } }
```

One should see a output like this:

```
{"account": { "activeCard": true, "availableLimit": 100 } }
{"transaction": { "merchant": "Burger King", "amount": 20, "time": "2019-02-13T10:00:00.000Z" } }
{"transaction": { "merchant": "Habbib's", "amount": 90, "time": "2019-02-13T11:00:00.000Z" } }
```

> The nginx logs will be printed in the current terminal, so ensure to validate the output or run the docker steps again

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/authorizer](https://hexdocs.pm/authorizer).

