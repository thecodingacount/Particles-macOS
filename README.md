# Particles - Hand-Tracked 3D Particle Simulation
A native macOS application built with SwiftUI, SceneKit, and Vision Framework that renders a 3D interactive particle system. Users can control the simulation using hand gestures captured via the webcam—pinch to zoom (scale) and grab to rotate.

## 🎥 Features
- **Real-time Hand Tracking**: Uses Apple's Vision framework to detect hand landmarks (index finger and thumb) from the webcam feed.
- **3D Particle Engine**: Renders thousands of particles using SceneKit (SCNParticleSystem) to create a stylized planet and ring system.
- **Interactive Gestures**:
  - **Pinch (Scale)**: Bring your index and thumb closer or further apart to scale the planet size dynamically.
  - **Grab & Rotate**: "Pinch" your fingers together (distance < 0.05) to lock the object, then move your hand to rotate the planet in 3D space.
- **Visual Aesthetics**:
  - **Core**: A golden, spherical particle emitter representing the planet's core.
  - **Ring**: A white, toroidal particle emitter creating a Saturn-like ring.
  - **Textures**: Custom programmatic circular textures for a clean, dot-matrix aesthetic.

## 🛠️ Tech Stack
- **Language**: Swift 5.0+
- **UI Framework**: SwiftUI
- **3D Engine**: SceneKit
- **Computer Vision**: Vision (VNDetectHumanHandPoseRequest) & AVFoundation
- **Platform**: macOS 13.5+ (optimized for Apple Silicon & Intel)

<!--## 🚀 Installation & Setup-->
<!--1. **Clone the Repository**:-->
<!--```bash-->
<!--   git clone https://github.com/zerosenseofcoding/particles-app.git-->
<!--   cd particles-app-->
<!--```-->
<!---->
<!--2. **Open in Xcode**: Double-click `Particles.xcodeproj` to open the project.-->
<!---->
<!--3. **Permissions**: Ensure you add the Camera Usage Description to your `Info.plist` file to allow webcam access:-->
<!--   - **Key**: `Privacy - Camera Usage Description`-->
<!--   - **Value**: `"We use the camera to track hand gestures for controlling the 3D simulation."`-->
<!---->
<!--4. **Run the App**:-->
<!--   - Select your Mac as the destination.-->
<!--   - Press `Cmd + R` to build and run.-->
<!--   - Grant camera permissions when prompted.-->

## 🎮 How to Use
1. **Launch the App**: You will see a black window with the particle system spinning (idle animation).
2. **Show Your Hand**: Raise your hand clearly in front of the webcam.
3. **Scale (Zoom)**: Keep your index finger and thumb visible.
   - Move apart to make the planet larger.
   - Move closer to make it smaller.
4. **Rotate**:
   - Pinch your index and thumb together tightly (like grabbing an object).
   - While holding the pinch, move your hand left/right or up/down to rotate the planet.
   - Release the pinch to stop rotating.

<!--## 🧩 Key Logic Snippets-->
<!--**Hand Tracking (Vision)**:-->
<!--```swift-->
<!--let request = VNDetectHumanHandPoseRequest()-->
<!--// ... perform request on sample buffer ...-->
<!--let indexTip = indexPoints[.indexTip]-->
<!--let thumbTip = thumbPoints[.thumbTip]-->
<!--// Calculate distance for pinch and position for rotation-->
<!--```-->
<!---->
<!--**Particle Setup (SceneKit)**:-->
<!--```swift-->
<!--let coreSystem = SCNParticleSystem()-->
<!--coreSystem.emitterShape = SCNSphere(radius: 1.0)-->
<!--// Using empty SCNNode() to hide the solid emitter shape-->
<!--particleNode = SCNNode()-->
<!--particleNode.addParticleSystem(coreSystem)-->
<!--```-->

## ⚠️ Troubleshooting
- **"Camera not working"**: Check System Settings > Privacy & Security > Camera and ensure Xcode/Particles has permission.
- **"Particles look square"**: Ensure `createCircleImage()` is correctly generating the NSImage and applied to `particleSystem.particleImage`.
- **"Rotation is jerky"**: Improve lighting in your room so the Vision framework can detect your fingers more stably.

## 📜 License
This project is open-source and available under the MIT License.

---
## 🏷️ Credits

**Developed by:** [TheCodingAccount](https://www.youtube.com/@thecodingaccount)  
**Made with:** SwiftUI • CoreML • Vision • SceneKit  


---

## 📣 Connect

If you liked the project, drop a ⭐ on GitHub or share your thoughts on [Instagram](https://www.instagram.com/thecodingaccount/). You can also follow me on [X](https://x.com/thecodingacount).Let’s redefine how we listen, one gesture at a time. 

☕️ Support the madness (and my coffee bill): [https://razorpay.me/@akshatsriv_07](https://razorpay.me/@akshatsriv_07)
