//
//  VideoViewController.swift
//  Experiences-Sprint
//
//  Created by David Doswell on 10/20/18.
//  Copyright © 2018 David Doswell. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class VideoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    var experienceController: ExperienceController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCapture()
    }
    
    @IBAction func toggleRecord(_ sender: Any) {
        if recordOutput.isRecording {
            recordOutput.stopRecording()
            saveRecording()
            pushToMapView()
        } else {
            recordOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    func saveRecording() {
        let noImage = UIImage()
        let noRealImage = noImage.pngData()
        
        guard let audio = recordOutput.outputFileURL else { return }
        experienceController?.updateVideoURL(with: "", image: noRealImage, audio: audio)
    }
    
    func pushToMapView() {
        let vc = MapViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.updateViews()
        }
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            self.updateViews()
        }
        
        PHPhotoLibrary.requestAuthorization { (status) in
            if status != .authorized {
                NSLog("Please give me access")
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
            }, completionHandler: { (success, error) in
                if let error = error {
                    NSLog("Error: \(error)")
                }
            })
        }
    }
    
    private func updateViews() {
        guard isViewLoaded else { return }
        
        let recordButtonImageName = recordOutput.isRecording ? "Stop" : "Record"
        record.setImage(UIImage(named: recordButtonImageName)!, for: .normal)
    }
    
    private func setUpCapture() {
        let captureSession = AVCaptureSession()
        let device = bestCamera()
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(videoDeviceInput) else {
                fatalError()
        }
        captureSession.addInput(videoDeviceInput)
        
        let fileOutput = AVCaptureMovieFileOutput()
        guard captureSession.canAddOutput(fileOutput) else { fatalError() }
        captureSession.addOutput(fileOutput)
        recordOutput = fileOutput
        
        captureSession.sessionPreset = .hd1920x1080
        captureSession.commitConfiguration()
        
        self.captureSession = captureSession
        previewView.videoPreviewLayer.session = captureSession
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.stopRunning()
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        } else {
            fatalError("Missing expected back camera")
        }
    }
    
    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let documentsDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    }
    
    private var captureSession: AVCaptureSession!
    private var recordOutput: AVCaptureMovieFileOutput!
    
    @IBOutlet weak var previewView: CameraPreviewView!
    @IBOutlet weak var record: UIButton!
}
