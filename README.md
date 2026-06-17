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

## Enrollment (multi-person, multi-angle)

Multiple people can be enrolled (1:N recognition). Each enrolled person is
stored with a **name**, a **face photo**, and one or more angle **templates**
(`FaceProfile` in `FaceProfileStore`; photos are saved as JPEGs in the app
documents directory). The home screen lists everyone enrolled with their photo,
and supports per-person delete and clear-all.

**Add Person (Guided)** walks the user through a short sequence of head poses
(front → right → left → up/down) and **auto-captures** one embedding per pose
once the head angle is held steady and the face is close enough, saving the
front pose as the profile photo, then prompts for a name. Accuracy improves
because the live frame is scored against **every** template and accepted on the
closest (max cosine similarity), so a turned or differently lit face still
matches its nearest enrolled angle.

At recognition time the app identifies **which** enrolled person best matches
and shows their name and photo. The number of angle samples and the minimum
face size are configurable on the **Recognition Settings** page. A **Quick
Enroll (1 photo)** option adds a person from a single frontal shot.

The UI is dark-themed throughout.

## Anti-Spoofing / Liveness

Live recognition gates every match behind a configurable liveness check that a
printed photo or replayed video cannot satisfy on demand:

* **Blink** — detects an open → closed → open eye sequence.
* **Head turn** — detects head yaw past a configurable angle.
* **Smile** — detects a smile past a configurable probability.

Each challenge can be toggled on/off to form a *pool*. With **Randomize
challenge** enabled (default), one challenge is picked at random from the pool
on every attempt — and re-picked on each retry — so a pre-recorded video can't
anticipate which action will be asked (sometimes blink, sometimes smile, etc.).
Turn randomization off to instead require *all* enabled challenges every time.

All thresholds (plus the match threshold and an overall liveness timeout) are
tweakable from the in-app **Recognition Settings** page (gear icon on the home
screen). An identity is accepted only when the liveness challenge passes *and*
the embedding similarity clears the match threshold.

The checks reuse Google ML Kit's face classification signals
(`eyeOpenProbability`, `headEulerAngleY`, `smilingProbability`), so no extra
model is bundled.

### Passive texture/CNN anti-spoof (optional)

Scaffolding is wired in for a *passive* single-frame spoof detector
(`lib/app/core/helper/spoof_detector.dart`) that scores each frame as live vs.
spoof (print / screen-replay / mask) using a CNN texture model — no user action
required. It runs in the live flow right before a match is accepted and rejects
suspected spoofs; it composes with the active liveness checks above.

**No model ships with the repo.** To activate it:

1. Obtain a trained classifier (e.g. a MiniFASNet from
   [Silent-Face-Anti-Spoofing](https://github.com/minivision-ai/Silent-Face-Anti-Spoofing)
   converted to TFLite) and place it at **`asset/antispoof.tflite`**.
2. Review the model-specific constants in `SpoofDetector` (input size,
   normalization, output layout, the "live" class index) — defaults assume an
   80×80, 3-class (print/live/replay) MiniFASNet export.
3. Enable **Passive anti-spoof** and tune **Min live probability** on the
   Recognition Settings page.

Until a model is present the check fails *open* (skipped) and the live screen
shows a one-line warning. Note these models are sensitive to camera/lighting
**domain shift**, so validate and tune the threshold on your target devices.

## Future Improvements

* Multi-face recognition
* Texture/CNN-based passive anti-spoofing model
* Cloud synchronization
* User enrollment system

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to improve.

## License

This project is licensed under the MIT License.

## Developer

**Nafis Hasrat Arnob**

Flutter Developer

GitHub: https://github.com/arnb13
