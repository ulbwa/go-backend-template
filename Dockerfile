FROM golang:1.26-alpine AS builder
WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/app ./cmd/main.go

FROM scratch
USER 10001:10001
COPY --from=builder /out/app /app
ENTRYPOINT ["/app"]
