#!/bin/bash
echo "Build docker image company/authorizer:0.1.0"
docker build -f Dockerfile-multi-stage -t company/authorizer:0.1.0 .

