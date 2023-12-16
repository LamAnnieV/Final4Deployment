# Use an official Ubuntu runtime as a parent image
FROM ubuntu:latest

# Install stress-ng
RUN apt-get update && \
    apt-get install -y stress-ng

# Define default command
CMD ["stress-ng", "--cpu", "2", "--vm", "1", "--io", "4", "--timeout", "10s"]
