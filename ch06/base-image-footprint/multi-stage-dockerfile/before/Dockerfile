FROM golang:1.19.4-alpine
WORKDIR /app

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go test -v
RUN go build -o /go-sample-app .
CMD ["/go-sample-app"]