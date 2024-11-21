FROM golang:1.23.3 AS builder

WORKDIR /p2p/app

#Allows to run the go app without any dependency 
ENV GO111MODULE=off CGO_ENABLED=0 

COPY . .

RUN go build -o main .

FROM alpine:latest

RUN apk --no-cache add ca-certificates

RUN addgroup -S p2p-user && adduser -S p2p-user -G p2p-user

WORKDIR /home/p2p-user/

COPY --from=builder /p2p/app/main .

RUN chown p2p-user:p2p-user main

# Switch to the non-root user
USER p2p-user

EXPOSE 3000

CMD ["./main"]
