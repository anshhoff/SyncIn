# SyncIn

## Overview
SyncIn is an application designed to bridge the gap between individuals within close proximity, enabling effortless interaction. The app identifies users within a predefined geofenced area, allowing them to connect based on shared interests, goals, or networking preferences. It provides a seamless user experience with a modern UI and integrates with Firebase for backend services.

## Features
- Geofencing-based user discovery
- Interest-based connections
- Secure and seamless communication

## Installation & Setup

### Prerequisites
Ensure you have the following installed:
- Xcode (latest version recommended)
- CocoaPods (`sudo gem install cocoapods`)

### Steps
1. Clone the repository:
   ```sh
   git clone https://github.com/anshhoff/SyncIn.git
   cd SyncIn
   ```
2. Install dependencies:
   ```sh
   pod install
   ```
3. Open the project in Xcode:
   ```sh
   open SyncIn.xcworkspace
   ```
4. Ensure you have configured Firebase by adding your `GoogleService-Info.plist` file to the project.
5. Build and run the app on a simulator or a connected device.

## Dependencies
- Firebase
- SwiftUI / UIKit (based on your UI approach)
- Other dependencies listed in `Podfile`

## Contributing
Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Commit your changes (`git commit -m "Added new feature"`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a Pull Request.
