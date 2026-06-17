# Face Recognition

A Flutter-based real-time face recognition and liveness verification system powered by Google ML Kit and TensorFlow Lite.

The application supports multi-person enrollment, multi-angle face recognition, active liveness detection (blink, smile, head-turn), and optional CNN-based passive anti-spoofing. All recognition runs entirely on-device, enabling fast, offline, and privacy-friendly biometric verification.

## Features

### Face Recognition

* 📷 Real-time camera stream processing
* 👤 Face detection using Google ML Kit
* 🧠 Face embedding generation using TensorFlow Lite (FaceNet/MobileFaceNet)
* 🔍 Cosine similarity-based face matching
* ⚡ Fast on-device inference
* 📱 Cross-platform Flutter support (Android & iOS)

### Multi-Person Enrollment

* Register multiple individuals
* Store names, profile photos, and embeddings
* Guided multi-angle enrollment
* Automatic pose detection and capture
* Quick single-photo enrollment option
* Local profile persistence

### Multi-Angle Recognition

* Front-facing recognition
* Left and right profile matching
* Up/down pose support
* Improved recognition accuracy across head orientations
* Best-match selection across all enrolled templates

### Liveness Detection

* 👁 Blink detection
* 😊 Smile detection
* 🔄 Head-turn verification
* Randomized challenge selection
* Configurable thresholds and timeout settings

### Anti-Spoofing

* Active liveness verification
* Optional passive CNN-based anti-spoofing
* Protection against:

  * Printed photos
  * Screen replay attacks
  * Recorded videos
  * Basic presentation attacks

### User Experience

* Dark-themed UI
* Recognition settings page
* Adjustable recognition thresholds
* Enrollment management
* Individual profile deletion
* Clear-all profile support

## Key Capabilities

### Enrollment Workflow

```text
Camera Preview
      ↓
Face Detection
      ↓
Guided Pose Capture
      ↓
Generate Face Embeddings
      ↓
Save Profile Photo
      ↓
Store Multiple Templates
      ↓
Enroll Person
```

### Recognition Workflow

```text
Live Camera Feed
      ↓
Face Detection
      ↓
Liveness Check
      ↓
Face Embedding Generation
      ↓
Compare Against Stored Profiles
      ↓
Best Match Selection
      ↓
Identity Verification
```

### Security Workflow

```text
Face Detection
      ↓
Liveness Challenge
      ↓
(Optional) Passive Anti-Spoofing
      ↓
Face Recognition
      ↓
Identity Accepted
```

## Use Cases

* Employee Attendance Systems
* Visitor Management
* Face-Based Authentication
* Identity Verification
* NID Verification Systems
* Access Control Solutions
* Smart Office Applications
* Educational Attendance Tracking



## Developer

**Nafis Hasrat Arnob**

Flutter Developer

GitHub: https://github.com/arnb13
