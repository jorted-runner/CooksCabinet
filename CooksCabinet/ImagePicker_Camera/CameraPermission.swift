//
//  CameraPermission.swift
//  CameraPhotoProto
//
//  Created by Danny Ellis on 2/11/25.
//
//  This file defines the `CameraPermission` enum, which handles checking
//  camera access permissions and provides user-friendly error messages
//  if access is restricted or unavailable.
//

import UIKit
import AVFoundation

/// `CameraPermission` handles checking if the app has permission to use the camera.
/// It also provides error messages and recovery suggestions if access is denied.
enum CameraPermission {
    /// Defines camera-related errors that may occur when accessing the camera.
    enum CameraError: Error, LocalizedError {
        // The user has denied camera access in settings.
        case unauthorized
        
        // The device does not support a camera.
        case unavailable
        
        /// Provides a user-friendly description of the error.
        var errorDescription: String? {
            switch self {
            case .unauthorized:
                // Shown when the user has denied camera access
                return NSLocalizedString("Camera access is required to take photos.", comment: "")
            case .unavailable:
                // Shown when the device does not support a camera
                return NSLocalizedString("Camera is unavailable on this device.", comment: "")
            }
        }
        
        /// Suggests how the user can resolve the camera error.
        var recoverySuggestion: String? {
            switch self {
            case .unauthorized:
                // Guides the user to enable camera permissions in settings
                return NSLocalizedString("Go to Settings > Privacy > Camera to allow access.", comment: "")
            case .unavailable:
                // Suggests an alternative to using the camera
                return NSLocalizedString("Use the photo album instead.", comment: "")
            }
        }
    }
    
    /// Checks if the app has permission to access the camera.
    /// - Returns: A `CameraError` if access is denied or the camera is unavailable; otherwise, returns `nil`.
    static func checkPermissions() -> CameraError? {
        // Check if the device has a camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // Get the camera authorization status
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch authStatus {
            case .notDetermined:
                // Permission has not been requested yet
                return nil
            case .restricted:
                // Access is restricted by parental controls (no action can be taken)
                return nil
            case .denied:
                // User has denied camera access
                return .unauthorized
            case .authorized:
                // Camera access is granted
                return nil
            @unknown default:
                // Handle any future cases Apple may introduce
                return nil
            }
        } else {
            // The device does not have a camera
            return .unavailable
        }
    }
}
