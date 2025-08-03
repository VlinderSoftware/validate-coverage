FROM alpine:3.18

# Install required packages for coverage validation
RUN apk add --no-cache \
    bash \
    bc \
    libxml2-utils \
    jq \
    curl

# Copy the validation script
COPY validate-coverage.sh /validate-coverage.sh

# Make the script executable
RUN chmod +x /validate-coverage.sh

# Set the entrypoint
ENTRYPOINT ["/validate-coverage.sh"]
