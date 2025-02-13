//
//  UIKitCamera.swift
//  CameraPhotoProto
//
//  Created by Danny Ellis on 2/11/25.
//

import SwiftUI

struct UIKitCamera: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {
        
    }
    
    func makeCoordinator() -> Coordniator {
        Coordniator(parent: self)
    }
    
    final class Coordniator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: UIKitCamera
        
        init(parent: UIKitCamera) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
    }
    
}
