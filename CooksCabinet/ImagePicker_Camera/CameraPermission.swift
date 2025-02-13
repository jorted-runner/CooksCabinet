//
//  CameraPermission.swift
//  CameraPhotoProto
//
//  Created by Danny Ellis on 2/11/25.
//

import UIKit
import AVFoundation

enum CameraPermission {
    enum CameraError: Error, LocalizedError {
        case unauthorized
        case unavailable
        
        var errorDescription: String? {
            switch self {
            case .unauthorized:
                return NSLocalizedString("Camera access is required to take photos.", comment: "")
            case .unavailable:
                return NSLocalizedString("Camera is unavailable on this device.", comment: "")
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .unauthorized:
                return NSLocalizedString("Go to Settings > Privacy > Camera to allow access.", comment: "")
            case .unavailable:
                return NSLocalizedString("Use the photo album instead.", comment: "")
            }
        }
    }
    static func checkPermissions() -> CameraError? {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let authStatus = AVCaptureDevice.authorizationStatus(
                for: AVMediaType.video
            )
            switch authStatus {
            case .notDetermined:
                return nil
            case .restricted:
                return nil
            case .denied:
                return .unauthorized
            case .authorized:
                return nil
            @unknown default:
                return nil
            }
        } else {
            return .unavailable
        }
    }
}
