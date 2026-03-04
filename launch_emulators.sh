#!/bin/bash
flutter emulators --launch apple_ios_simulator &
flutter emulators --launch Medium_Phone_API_36.1 &
echo "Emulators launched! To run the app on both, use:"
echo "flutter run -d all"
