ARG port=8081
ARG app=service-a

FROM docker.io/library/golang as builder
ARG app
WORKDIR /app

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY ${app}/ ${app}
COPY lib/ lib

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/${app} ./${app}

# final stage
FROM docker.io/library/alpine
ARG app
ARG port
COPY --from=builder /out/${app} /app/

EXPOSE ${port}
ENTRYPOINT ["/app/service-a"]
