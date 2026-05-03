# BrewTrack

BrewTrack is a native SwiftUI cafe inventory app for adding products, tracking stock, managing supplier debt, and reviewing restock alerts and inventory history.

## Setup

1. Open `BrewTrackSwiftUI/BrewTrack.xcodeproj` in Xcode.
2. Let Xcode resolve the Firebase Swift Package dependencies.
3. Select the `BrewTrack` scheme.
4. Choose an iPhone simulator or connected device.
5. Build and run.

The app targets iOS 16 or later.

## Firebase

The app uses Firebase Authentication and Cloud Firestore.

1. Add `BrewTrackSwiftUI/GoogleService-Info.plist` to the Xcode target.
2. Enable Email/Password sign-in in Firebase Authentication.
3. Create a Cloud Firestore database.
4. Run the app and create an account. Starter inventory data is seeded for the signed-in user.

## Features

- Email/password login and signup.
- Firestore-backed inventory data per user.
- Add, view, edit, and delete inventory items.
- Search, sort, and stock-status filters.
- Supplier debt tracking with Mark Paid actions.
- Low-stock and out-of-stock alerts.
- Inventory history with action filters.
- Smart restock and supplier insights.
- Patrick Hand font styling with spacing fixes for readable labels and prices.
