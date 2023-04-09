# Use an official Xcode image as the base image
FROM inloco/xcode

# Install additional dependencies, if needed
RUN apt-get update && apt-get install -y bash

# Set up your project directory and copy the code
WORKDIR /app
COPY . .

# Run tests with XCTest
RUN /bin/bash -c "xcodebuild build-for-testing test-without-building -project WordyMe.xcodeproj -scheme WordFeatureTests -destination 'platform=iOS Simulator,name=iPhone 12 Pro Max'"
