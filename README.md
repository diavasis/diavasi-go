# Go client

[![CI](https://github.com/diavasis/diavasi-go/actions/workflows/ci.yml/badge.svg)](https://github.com/diavasis/diavasi-go/actions/workflows/ci.yml)
[![Go Reference](https://pkg.go.dev/badge/github.com/diavasis/diavasi-go.svg)](https://pkg.go.dev/github.com/diavasis/diavasi-go)
[![license](https://img.shields.io/github/license/diavasis/diavasi-go)](https://github.com/diavasis/diavasi-go/blob/main/LICENSE)

Module `github.com/diavasis/diavasi-go` version 0.1.0. `Consume` opens a TLS stream to `diavasi.data.v1`, sends the bearer token, Hello version 1, then JoinGroup, and acks each batch. The client stores no cursor and does not dedupe on `record_id`. A dropped stream is how unacked batches return. Reconnect with the same consumer id and the server replays them.

`proto/data.proto` in this repository is the copy of `diavasi.data.v1` from [github.com/diavasis/diavasi](https://github.com/diavasis/diavasi) tag `v0.12.0`.

## Install

```bash
go get github.com/diavasis/diavasi-go@v0.1.0
```

## Library

```go
report, err := diavasi.Consume(ctx, diavasi.Options{
    Addr:          "127.0.0.1:7710",
    CAFile:        "/tmp/diavasi-sdk/dataplane-ca.crt",
    Token:         "sdk-demo",
    GroupID:       "demo",
    ConsumerID:    "go",
    ExpectRecords: 8,
})
```

`MaxInFlight` defaults to 1. `HaltAfterAcks` closes after that many acks and does not send Leave. `ExpectRecords` sends Leave once that many records are acked.

`*ProtocolError` carries codes 1 through 8: bad version, bad state, unknown ack, duplicate ack, group not running, unsupported, internal, heartbeat timeout. `*CallError` is a gRPC status. A bad token is `UNAUTHENTICATED` with message `unauthorized`. A group that is not running is protocol code 5.

## Example

```bash
go run ./cmd/consume --addr 127.0.0.1:7710 --ca /tmp/diavasi-sdk/dataplane-ca.crt \
  --token sdk-demo --group demo --consumer go --total 8
```

Flags: `--addr`, `--ca`, `--token`, `--group`, `--consumer`, `--total`, `--max-in-flight` (default 1), `--halt-after`. The last occurrence of a flag wins. The command prints `record_ids` and `batch_ids`.

```bash
docker compose -f clients/docker-compose.yml --profile go up --abort-on-container-exit
```

## Test

`go test ./...` always runs the frame codec tests. The server cases skip until `DIAVASI_DATA_ADDR`, `DIAVASI_CA`, and `DIAVASI_API_TOKEN` are set.
