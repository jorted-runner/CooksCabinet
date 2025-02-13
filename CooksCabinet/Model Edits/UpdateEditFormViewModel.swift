//
//  UpdateEditFormViewModel.swift
//  CameraPhotoProto
//
//  Created by Danny Ellis on 2/11/25.
//

import UIKit

@Observable
class UpdateEditFormViewModel {
    var title: String = ""
    var data: Data?
    
    var recipe: RecipeModel?
    var cameraImage: UIImage?
    
    var image: UIImage {
        if let data, let uiImage = UIImage(data: data) {
            return uiImage
        } else {
            return Constants.placeholder
        }
    }
    
    init() {}
    
    init (recipe: RecipeModel) {
        self.recipe = recipe
        self.title = recipe.title
        self.data = recipe.data
    }
    
    @MainActor
    func clearImage() {
        data = nil
    }
    
    var isUpDating: Bool { recipe != nil }
    var isDisabled: Bool { title.isEmpty }
}
