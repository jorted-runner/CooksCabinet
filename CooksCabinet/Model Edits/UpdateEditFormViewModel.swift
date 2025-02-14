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
    
    // New properties to store recipe details
    var ingredients: [String] = []
    var instructions: [String] = []
    var recipeDescription: String = ""
    
    var image: UIImage {
        if let data, let uiImage = UIImage(data: data) {
            return uiImage
        } else {
            return Constants.placeholder
        }
    }
    
    init() {}
    
    init(recipe: RecipeModel) {
        self.recipe = recipe
        self.title = recipe.title
        self.data = recipe.data
        self.ingredients = recipe.ingredients
        self.instructions = recipe.instructions
        self.recipeDescription = recipe.recipeDescription
    }
    
    @MainActor
    func clearImage() {
        data = nil
    }
    
    var isUpDating: Bool { recipe != nil }
    var isDisabled: Bool { title.isEmpty }
}
