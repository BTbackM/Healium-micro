#!/bin/bash

SERVICE_NAME=$1
VERSION=$2

# Config git
git config --global user.name "BTbackM"
git config --global user.email "felix.blanco@utec.edu.pe"
git fetch --all && git checkout main

# Install protoc
sudo apt-get install -y protobuf-compiler golang-goprotobuf-dev
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

mkdir -p ./golang/${SERVICE_NAME}
# Generate proto files
protoc \
  --go_out=paths=source_relative:./golang \
  --go-grpc_out=paths=source_relative:./golang \
  ./${SERVICE_NAME}/*.proto

# Generate go mod
cd ./golang/${SERVICE_NAME}
go mod init github.com/BTbackM/Healium-micro/src/protos/golang/${SERVICE_NAME} || true
go mod tidy

# Commit and push changes
git add .
git commit -m "chore: generate proto files for ${SERVICE_NAME}"
git push origin HEAD:main
git tag -fa golang/${SERVICE_NAME}/v${VERSION} -m "chore: release ${SERVICE_NAME} v${VERSION}"
git push origin refs/tags/golang/${SERVICE_NAME}/v${VERSION}
