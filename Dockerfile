FROM golang:1.23-bookworm
WORKDIR /src
COPY . /src
RUN go mod download && go build -o /consume ./cmd/consume
RUN chmod +x /src/wait-ca.sh
CMD ["/bin/sh", "-c", "/src/wait-ca.sh && /consume --addr \"$DIAVASI_DATA_ADDR\" --ca \"$DIAVASI_CA\" --token \"$DIAVASI_API_TOKEN\" --group demo --consumer go --total 8"]
