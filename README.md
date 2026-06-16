# Face Recognition

A Flutter-based real-time face recognition system using camera stream, face detection, and face embedding generation with TensorFlow Lite (FaceNet/MobileFaceNet).

This project detects faces from a live camera feed, extracts facial embeddings, and compares them for face recognition and verification.

## Features

* 📷 Real-time camera stream
* 👤 Face detection from live video feed
* 🧠 Face embedding generation using TensorFlow Lite
* 🔍 Face matching and recognition
* ⚡ Fast and lightweight on-device inference
* 📱 Cross-platform Flutter support (Android & iOS)

## Tech Stack

### Frontend

* Flutter

### AI / ML

* TensorFlow Lite
* FaceNet / MobileFaceNet
* Google ML Kit Face Detection

### Packages Used

* `camera`
* `google_mlkit_face_detection`
* `tflite_flutter`
* `image`
* `permission_handler`

## Project Workflow

```text
Camera Stream
      ↓
Face Detection (ML Kit)
      ↓
Face Cropping
      ↓
Image Preprocessing
      ↓
Face Embedding (TFLite Model)
      ↓
Face Comparison
      ↓
Recognition Result
```

## Screenshots

Add screenshots here.

```md
![Home Screen](screenshots/home.png)
![Face Detection](screenshots/detection.png)
```

## Installation

### Clone the repository

```bash
git clone https://github.com/arnb13/face_recognition.git
```

### Navigate to project folder

```bash
cd face_recognition
```

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

## Required Permissions

### Android

Add these permissions in:

`android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

## Model Setup

Place the TensorFlow Lite model inside:

```text
assets/models/
```

Example:

```text
assets/models/mobile_face_net.tflite
```

Make sure to add it in `pubspec.yaml`:

```yaml
assets:
  - assets/models/
```

## Use Cases

* Attendance system
* Employee verification
* User authentication
* Face-based login
* NID/identity verification
* Visitor management

## Future Improvements

* Multi-face recognition
* Face anti-spoofing
* Liveness detection
* Cloud synchronization
* User enrollment system

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to improve.

## License

This project is licensed under the MIT License.

## Developer

**Nafis Arnob**
Flutter Developer

GitHub: https://github.com/arnb13
