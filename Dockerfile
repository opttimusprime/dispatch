FROM golang:1.22-alpine AS build

# Set working directory
WORKDIR /app

# Copy source code
COPY . .

# Initialize module if needed, download dependencies, build binary
RUN go mod init dispatch || true
RUN go mod tidy
RUN go build -o dispatch

FROM alpine:3.19

# Set working directory
WORKDIR /app

# Copy built binary
COPY --from=build /app/dispatch /app/dispatch

# Create non-root user
RUN addgroup -S roboshop && adduser -S roboshop -G roboshop

# Give ownership
RUN chown -R roboshop:roboshop /app

# Set environment variables
ENV AMQP_HOST=rabbitmq
ENV AMQP_USER=roboshop
ENV AMQP_PASS=roboshop123

# Switch user
USER roboshop

# Start app
CMD ["/app/dispatch"]