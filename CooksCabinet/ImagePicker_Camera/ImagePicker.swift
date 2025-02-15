//
//  ImagePicker.swift
//  CameraPhotoProto
//
//  Created by Danny Ellis on 2/11/25.
//
//  This file defines the `ImagePicker` class, which handles selecting images
//  from the user's photo library using the `PhotosPicker` API in SwiftUI.
//  It supports loading a single image and storing it in the associated
//  `UpdateEditFormViewModel`.
//

import SwiftUI
import PhotosUI    // Enables image selection from the photo library

/// `ImagePicker` is responsible for selecting and handling images from the user's photo library.
/// - Uses `PhotosPickerItem` to fetch images.
/// - Supports loading a single image.
/// - Stores the selected image in `UpdateEditFormViewModel`.
@Observable
class ImagePicker {
    /// The currently selected image (converted to SwiftUI's `Image` type).
    var image: Image?
    
    /// Array to store multiple selected images (not currently used but reserved for future functionality).
    var images: [Image] = []
    
    /// ViewModel reference to update with selected image data.
    var vm: UpdateEditFormViewModel?
    
    /// Sets up the `ImagePicker` with a reference to `UpdateEditFormViewModel`.
    /// - Parameter vm: The ViewModel instance to update with image data.
    func setup(_ vm: UpdateEditFormViewModel) {
        self.vm = vm
    }
    
    /// Selected image from the `PhotosPicker`.
    /// - When a new image is selected, `loadTransferable(from:)` is called asynchronously
    ///   to process and store the image.
    var imageSelection: PhotosPickerItem? {
        didSet {
            if let imageSelection {
                Task {
                    try await loadTransferable(from: imageSelection)
                }
            }
        }
    }
    
    /// Loads and processes the selected image from the photo picker.
    /// - Parameter imageSelection: The selected `PhotosPickerItem`.
    /// - This function:
    ///   - Retrieves image data asynchronously.
    ///   - Updates the `UpdateEditFormViewModel` with the image data.
    ///   - Converts the data into a `UIImage` and stores it in `image`.
    @MainActor
    func loadTransferable(from imageSelection: PhotosPickerItem?) async throws {
        do {
            if let data = try await imageSelection?.loadTransferable(type: Data.self) {
                vm?.data = data
                if let uiImage = UIImage(data: data) {
                    self.image = Image(uiImage: uiImage)
                }
            }
        } catch {
            print(error.localizedDescription)
            image = nil
        }
    }
}
