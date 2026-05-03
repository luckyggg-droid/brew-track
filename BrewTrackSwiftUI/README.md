# Brew & Track SwiftUI

This folder contains the native SwiftUI version of Brew & Track, a cafe inventory manager for adding items, tracking stock, watching supplier debt, and surfacing smart restock insights.

## Architecture

- `BrewTrack/BrewTrackApp.swift` contains the app entry point and Firebase startup.
- `BrewTrack/Models` contains inventory, history, supplier, tab, and status models.
- `BrewTrack/ViewModels` contains `InventoryViewModel` and `AuthViewModel`, the MVVM state and user actions layer.
- `BrewTrack/Services` contains Firestore persistence, smart insight generation, font registration, and formatting helpers.
- `BrewTrack/Views` contains the SwiftUI screens and form.
- `BrewTrack/Components` contains reusable UI pieces such as cards, chips, buttons, empty states, and flow layout.
- `BrewTrack/Theme` contains the visual color system and Patrick Hand font helpers.

## Run in Xcode

1. Open `BrewTrack.xcodeproj` in Xcode.
2. Let Xcode resolve the Firebase Swift Package dependencies.
3. Select the `BrewTrack` scheme.
4. Choose an iPhone simulator or connected device.
5. Build and run.

The project targets iOS 16 or later because it uses SwiftUI `Layout` for wrapping supplier chips.

## Firebase Setup

The project uses Firebase Auth and Cloud Firestore.

1. Add `GoogleService-Info.plist` to the Xcode project and make sure it is included in the `BrewTrack` target.
2. In Firebase Console, enable **Authentication > Sign-in method > Email/Password**.
3. In Firebase Console, create a **Cloud Firestore** database. Test mode is fine for the take-home demo.
4. Run the app, create an account, and the starter cafe inventory will be seeded under that user's Firestore document.

## Current Features

- Inventory CRUD: add, view, edit, and delete items.
- Firebase email/password sign in, create account, and sign out.
- Firestore-backed inventory and history persistence per signed-in user.
- Search, sort, and stock-status filters.
- Supplier debt tracking and mark-paid actions.
- Alerts screen for low/out-of-stock items.
- History screen with action filtering.
- Smart inventory insights that surface low stock, out-of-stock items, highest supplier debt, total debt pressure, and dairy bulk-order opportunities.
- Loading, empty, validation, and toast states.
- Patrick Hand font styling throughout the app.
