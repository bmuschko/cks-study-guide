FROM golang:1.19.4-alpine AS build
RUN apk add --no-cache git
WORKDIR /tmp/image-validation-webhook
COPY go.mod .
RUN go mod download
COPY . .

RUN CGO_ENABLED=0 go test -v
RUN go build -o ./out/image-validation-webhook .

FROM alpine:3.17.0
RUN apk add ca-certificates
COPY --from=build /tmp/image-validation-webhook/out/image-validation-webhook /app/image-validation-webhook
COPY --from=build /tmp/image-validation-webhook/certs /app/certs
ADD --chown=root:root certs/* /certs/
CMD ["/app/image-validation-webhook"]