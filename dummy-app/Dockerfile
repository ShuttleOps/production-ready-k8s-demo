FROM golang:1.15

# Set the Current Working Directory inside the container
WORKDIR $GOPATH/src/github.com/Indellient/dummy-app

# Copy everything from the current directory to the PWD (Present Working Directory) inside the container
COPY main.go .

# Download all the dependencies
RUN go get -d -v ./...

# Install the package
RUN go build -o dummyapp

# Run the executable
CMD ["./dummyapp"]