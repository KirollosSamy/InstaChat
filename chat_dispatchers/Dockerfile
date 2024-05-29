FROM golang:1.20 AS base

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o main main.go


# Start a new stage to create a minimal image
FROM alpine:latest

WORKDIR /

COPY --from=base /app/main .
COPY --from=base /app/config/config.yaml /config/config.yaml

ENTRYPOINT ["./main"]