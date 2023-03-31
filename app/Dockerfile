# Start with the official Golang image as the base
FROM golang:1.20.2

# Set the working directory inside the container
WORKDIR /app

# Copy the Go modules files and download dependencies
COPY go.mod ./
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go application inside the container
RUN go build -o /bin/myapp

# Expose the port that the application listens to
EXPOSE 8080

# Set the command to run when the container starts
CMD ["/bin/myapp"]
