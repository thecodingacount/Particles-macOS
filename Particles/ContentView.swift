//
//  ContentView.swift
//  Particles
//
//  Created by @ZeroSenseOfCoding on 14/12/25.
//
// MARK: - Warranty void if you actually read the code. 😂

import SwiftUI
import AVFoundation
import SceneKit
import Vision
import Combine

struct ContentView: View {
    let scene = ParticleScene()
    @StateObject var tracker = HandTracker()
    
    var body: some View {
        ZStack {
            // [TWEAK] .allowsCameraControl:
            // Keep this 'true' if you want to use the mouse to look around for debugging.
            // Set to 'false' to strictly lock the view to hand gestures only.
            SceneView(scene: scene, options: [.allowsCameraControl, .autoenablesDefaultLighting])
                .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            tracker.particleScene = scene
        }
    }
}

class ParticleScene: SCNScene {
    var particleNode: SCNNode!
    var ringNode: SCNNode!
    var mainWrapper: SCNNode!
    
    override init() {
        super.init()
        setupScene()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupScene() {
        // [TWEAK] Background Color: Change to .white or .darkGray if needed.
        self.background.contents = NSColor.black
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // [TWEAK] Camera Position:
        // z = 10 is the distance. Lower (e.g., 5) zooms in, Higher (e.g., 20) zooms out.
        cameraNode.position = SCNVector3(0, 0, 10)
        self.rootNode.addChildNode(cameraNode)
        
        mainWrapper = SCNNode()
        self.rootNode.addChildNode(mainWrapper)
        
        let circleImg = createCircleImage()
        
        // --- CORE SPHERE SETUP ---
        // [TWEAK] Core Radius: The size of the invisible sphere emitting the center particles.
        let sphere = SCNSphere(radius: 1.0)
        particleNode = SCNNode()
        
        let coreSystem = SCNParticleSystem()
        
        // [TWEAK] Core Density (Birth Rate):
        // 5000 = Dense. Change to 1000 for sparse/airy look, or 10000 for a solid sun look.
        coreSystem.birthRate = 5000
        
        coreSystem.emissionDuration = 1.0
        coreSystem.emitterShape = sphere
        coreSystem.birthLocation = .surface
        
        // [TWEAK] Trail Length (Life Span):
        // 1.5 seconds. Increase to make particles trail longer. Decrease for snappy movement.
        coreSystem.particleLifeSpan = 1.5
        
        // [TWEAK] Core Particle Size: 0.04 is standard.
        coreSystem.particleSize = 0.04
        coreSystem.particleImage = circleImg
        
        // [TWEAK] Core Color: Current is Gold.
        // Change RGB values to customize (e.g., Red: 1.0, Green: 0.2 for a red sun).
        coreSystem.particleColor = NSColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1.0)
        
        coreSystem.blendMode = .additive
        
        // [TWEAK] Explosion Spread: 180 means particles fly in all directions.
        coreSystem.spreadingAngle = 180
        
        particleNode.addParticleSystem(coreSystem)
        mainWrapper.addChildNode(particleNode)
        
        
        // --- RING (SATURN) SETUP ---
        // [TWEAK] Ring Size: ringRadius (2.5) is width, pipeRadius (0.2) is thickness.
        let torus = SCNTorus(ringRadius: 2.5, pipeRadius: 0.2)
        ringNode = SCNNode()
        
        // [TWEAK] Ring Tilt: Adjust x/y/z to change the 3D angle of the ring.
        ringNode.eulerAngles = SCNVector3(x: 0.5, y: 0, z: 0.2)
        
        let ringSystem = SCNParticleSystem()
        
        // [TWEAK] Ring Density: 8000 particles.
        ringSystem.birthRate = 8000
        
        ringSystem.emissionDuration = 1.0
        ringSystem.emitterShape = torus
        ringSystem.birthLocation = .surface
        
        // [TWEAK] Ring Life Span: Needs to be long enough to look continuous.
        ringSystem.particleLifeSpan = 2.0
        
        // [TWEAK] Ring Particle Size: Usually smaller than core (0.01).
        ringSystem.particleSize = 0.01
        ringSystem.particleImage = circleImg
        
        // [TWEAK] Ring Color: Currently White.
        ringSystem.particleColor = NSColor.white
        // ringSystem.particleColor = NSColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0) // Uncomment for Blue
        
        ringSystem.blendMode = .additive
        
        ringNode.addParticleSystem(ringSystem)
        mainWrapper.addChildNode(ringNode)
        
        // [TWEAK] Idle Rotation Speed:
        // Duration 20 means one full spin takes 20 seconds. Lower = Faster.
        let rotateAction = SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 20)
        let loopAction = SCNAction.repeatForever(rotateAction)
        mainWrapper.runAction(loopAction, forKey: "idleRotation")
    }
    
    func createCircleImage() -> NSImage {
        // [TWEAK] Texture Quality: 20x20 is efficient.
        // Increasing size improves sharpness but reduces FPS.
        let size = NSSize(width: 20, height: 20)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.white.setFill()
        let path = NSBezierPath(ovalIn: NSRect(origin: .zero, size: size))
        path.fill()
        image.unlockFocus()
        return image
    }
    
    
    // --- GESTURE LOGIC: PINCH (ZOOM) ---
    func updatePinch(distance: CGFloat) {
        
        // [TWEAK] Zoom Sensitivity: 15.0 multiplier.
        // Increase this if you want the planet to grow faster with small finger movements.
        let targetScale = Float(distance) * 15.0
        
        let currentScale = mainWrapper.scale.x
        
        // [TWEAK] Smoothness (Lerp): 0.1 factor.
        // Lower (0.05) = Very smooth/lazy follow. Higher (0.5) = Instant snap.
        let newScale = currentScale + (CGFloat(targetScale) - currentScale) * 0.1
        
        // [TWEAK] Scale Limits: Min (0.5) and Max (4.0).
        let clampedScale = max(0.5, min(newScale, 4.0))
        
        mainWrapper.scale = SCNVector3(clampedScale, clampedScale, clampedScale)
        
        // [TWEAK] Dynamic Density:
        // When zoomed out (small < 1.0), increase particles (8000) for a solid look.
        // When zoomed in (large), decrease particles (4000) to save performance.
        if clampedScale < 1.0 {
            particleNode.particleSystems?.first?.birthRate = 8000
        } else {
            particleNode.particleSystems?.first?.birthRate = 4000
        }
    }
    
    // --- GESTURE LOGIC: ROTATION ---
    func handleRotation(dx: CGFloat, dy: CGFloat) {
            
            // Stop idle animation so the user is in full control
            mainWrapper.removeAction(forKey: "idleRotation")
            
            // [TWEAK] Rotation Sensitivity:
            // 5.0 is standard. Increase (e.g., 10.0) to spin faster on small movements.
            let sensitivity: CGFloat = 5.0
            
            mainWrapper.eulerAngles.y += dx * sensitivity
            mainWrapper.eulerAngles.x += dy * sensitivity
        }
}

class HandTracker: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    let session = AVCaptureSession()
    var particleScene: ParticleScene?
    
    var lastPinchPoint: CGPoint?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func setupCamera() {
        session.sessionPreset = .high
        
        // [NOTE] macOS Camera: This usually picks the webcam automatically.
        guard let device = AVCaptureDevice.default(for: .video), let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        if session.canAddInput(input) { session.addInput(input) }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if session.canAddOutput(output) { session.addOutput(output) }
        
        DispatchQueue.global().async { self.session.startRunning() }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let request = VNDetectHumanHandPoseRequest()
        // [TWEAK] Maximum Hands: Set to 1 for simplicity. Set to 2 if adding two-hand gestures.
        request.maximumHandCount = 1
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up)
        
        do {
            try handler.perform([request])
            guard let observation = request.results?.first else {
                // Hand lost: Reset pinch state
                DispatchQueue.main.async { self.lastPinchPoint = nil }
                return
            }
            
            let indexPoints = try observation.recognizedPoints(.indexFinger)
            let thumbPoints = try observation.recognizedPoints(.thumb)
            
            guard let indexTip = indexPoints[.indexTip], let thumbTip = thumbPoints[.thumbTip] else { return }
            
            // Math: Calculate distance between Thumb and Index finger
            let distanceX = indexTip.location.x - thumbTip.location.x
            let distanceY = indexTip.location.y - thumbTip.location.y
            let pinchDistance = sqrt(distanceX * distanceX + distanceY * distanceY)
            
            // Math: Calculate the midpoint (Center) between fingers
            let centerX = (indexTip.location.x + thumbTip.location.x) / 2
            let centerY = (indexTip.location.y + thumbTip.location.y) / 2
            let currentPoint = CGPoint(x: centerX, y: centerY)
            
            DispatchQueue.main.async {
                // LOGIC SPLIT:
                // [TWEAK] Mode Threshold (0.06):
                // Distance < 0.06 means "Grab/Pinch" -> Rotate Mode.
                // Distance > 0.06 means "Open Hand" -> Zoom/Scale Mode.
                if pinchDistance < 0.06 {
                    // --- ROTATION MODE ---
                    if let last = self.lastPinchPoint {
                        let dx = currentPoint.x - last.x
                        let dy = currentPoint.y - last.y
                        
                        self.particleScene?.handleRotation(dx: dx, dy: dy)
                    }
                    self.lastPinchPoint = currentPoint
                    
                } else {
                    // --- SCALE MODE ---
                    self.lastPinchPoint = nil
                    
                    self.particleScene?.updatePinch(distance: pinchDistance)
                }
            }
        } catch {
            print("Vision Error: \(error)")
        }
    }
}
