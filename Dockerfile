FROM golang:1.20-alpine AS builder
WORKDIR /build
RUN apk add --no-cache git
# Copy all the source
COPY . .
RUN go mod tidy && \
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o moosefs-csi ./cmd/moosefs-csi

FROM alpine:3.18
WORKDIR /app
COPY --from=builder /build/moosefs-csi /app/moosefs-csi
RUN chmod +x /app/moosefs-csi
ENTRYPOINT ["/app/moosefs-csi"]
CMD ["--endpoint=unix:///csi/csi.sock", "--nodeid=$(hostname)"]
