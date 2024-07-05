# Flutter/Dart SDK for connecting to the Semaphore server.

## Usage

Initializing the sdk.

```dart
final semaphore = await Semaphore.initialize(
    baseUrl: 'http://localhost:5000/v1/',
);
```
