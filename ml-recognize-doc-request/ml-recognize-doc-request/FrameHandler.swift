//
//  FrameHandler.swift
//  ml-recognize-doc-request
//
//  Created by Mich Ochieng on 2026-01-17.
//

import AVFoundation
import Combine
import CoreImage
import SwiftUI
import Vision

class FrameHandler: NSObject, ObservableObject {
    
    @Published var frame: CGImage?
    @Published var receipt: Receipt?
    @Published var isProcessing = false
    
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "session queue")
    private var permissionGranted = false
    private let context = CIContext()
    
    override init() {
        super.init()
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
        case .denied, .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
                self.permissionGranted = granted
            }
        default:
            permissionGranted = false
        }
    }
    
    func setupCaptureSession() {
        let videoOutput = AVCaptureVideoDataOutput()
        
        guard permissionGranted else { return }
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        guard captureSession.canAddInput(videoInput) else { return }
        captureSession.addInput(videoInput)
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Sample Queue"))
        captureSession.addOutput(videoOutput)
        
        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.addOutput(photoOutput)
        
        if let connection = videoOutput.connection(with: .video),
           connection.isVideoRotationAngleSupported(90) {
            connection.videoRotationAngle = 90
        }
        if let connection = photoOutput.connection(with: .video),
           connection.isVideoRotationAngleSupported(90) {
            connection.videoRotationAngle = 90
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    private func scanReceipt(from image: CGImage) async {
        await MainActor.run { self.isProcessing = true }
        
        do {
            let request = RecognizeDocumentsRequest()
            let observations = try await request.perform(on: image)
            let receipt = Receipt(image: image, observations: observations)
            await MainActor.run {
                self.receipt = receipt
                self.isProcessing = false
            }
        } catch {
            print("RecognizeDocumentsRequest failed: \(error)")
            await MainActor.run { self.isProcessing = false }
        }
    }
}

extension FrameHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cgImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        DispatchQueue.main.async { [unowned self] in
            self.frame = cgImage
        }
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return cgImage
    }
}

extension FrameHandler: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let ciImage = CIImage(data: data),
              let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        
        Task {
            await scanReceipt(from: cgImage)
        }
    }
}
