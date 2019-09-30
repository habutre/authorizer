#!/bin/bash
FORCE_STATIC_ANALYSIS=$1

echo "Starting package preparation for shipping"

echo "Updating dependencies"
MIX_ENV=prod mix do deps.get, deps.compile

echo "Performing application tests"
if [ "$FORCE_STATIC_ANALYSIS" = "-f" ]; then # way simple check
  mix do clean, compile, credo --strict, dialyzer && mix test
else
  mix do clean, compile, credo --strict && mix test
fi

echo "Prepare documentation"
MIX_ENV=prod mix compile && \
  ~/.mix/escripts/ex_doc "Authorizer" "0.1.0" \
  _build/prod/lib/authorizer/ebin \
  -m "Authorizer" \
  -u "https://git.acme.com/company/authorizer" && \
  MIX_ENV=prod mix escript.build

echo "Building Authorizer App"
MIX_ENV=prod mix escript.build

echo "Build docker image company/authorizer:0.1.0"
docker build -t company/authorizer:0.1.0 .

