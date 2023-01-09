FROM golang:1.19.4-alpine
WORKDIR /app
COPY main.go .
RUN go build main.go
CMD ["./main"]