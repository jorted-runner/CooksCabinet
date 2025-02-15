//
//  UIKitCamera.swift
//  CameraPhotoProto
//
//  Created by Danny Ellis on 2/11/25.
//
//  This file defines the `UIKitCamera` struct, which provides a SwiftUI interface
//  for capturing images using `UIImagePickerController`. It allows users to take
//  photos with the device's camera and return the selected image.
//

import SwiftUI

/// A SwiftUI wrapper for `UIImagePickerController` that enables users to take photos.
/// - Uses `UIViewControllerRepresentable` to bridge between UIKit and SwiftUI.
/// - Captured images are stored in `selectedImage`.
struct UIKitCamera: UIViewControllerRepresentable {
    /// The selected image captured by the camera.
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    /// Creates and configures a `UIImagePickerController` instance.
    /// - Parameter context: Provides the SwiftUI context for coordination.
    /// - Returns: A `UIImagePickerController` configured for camera capture.
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false  // Disable image editing
        imagePicker.sourceType = .camera  // Use the camera as the source
        imagePicker.delegate = context.coordinator  // Assign the coordinator as delegate
        return imagePicker
    }

    /// Upated the 'UIImagePickerController' when SwiftUI need to refresh it
    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {
        // No updates needed for now
    }
    
    /// Creates a coordinator to handle image selection events.
    func makeCoordinator() -> Coordniator {
        Coordniator(parent: self)
    }
    
    /// Coordinator class to manage interactions between `UIKitCamera` and `UIImagePickerController`.
    final class Coordniator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        /// Reference to the `UIKitCamera` instance to update `selectedImage`.
        var parent: UIKitCamera
        
        init(parent: UIKitCamera) {
            self.parent = parent
        }
        
        /// Handles image selection and assigns the picked image to `selectedImage`.
        /// - Parameters:
        ///   - picker: The `UIImagePickerController` instance.
        ///   - info: A dictionary containing image selection details.
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            // Retrieve the captured image and assign it to `selectedImage`
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            // Dismiss the camera view
            parent.dismiss()
        }
    }
    
}
