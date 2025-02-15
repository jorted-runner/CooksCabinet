//
//  UpdateEditFormViewModel.swift
//  CameraPhotoProto
//
//  Created by Danny Ellis on 2/11/25.
//
//  This ViewModel handles the logic for updating and editing recipes in the app.
//  It manages the recipe data, including title, ingredients, instructions, and images.
//

import UIKit


/// ViewModel for managing the update and edit form of a recipe.
/// - Uses `@Observable` for state management.
/// - Handles recipe data, including title, ingredients, and images.
/// - Provides methods for clearing images and tracking update states.
@Observable
class UpdateEditFormViewModel {
    var title: String = ""
    var data: Data?
    
    var recipe: RecipeModel?
    var cameraImage: UIImage?
    
    var ingredients: [String] = []
    var instructions: [String] = []
    var recipeDescription: String = ""
    
    /// Returns a `UIImage` representation of the recipe's image data.
    /// - If `data` exists and is valid, it converts it to a `UIImage`.
    /// - Otherwise, it returns a placeholder image.
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
    
    /// Clears the current recipe image.
    /// - This sets `data` to `nil`, effectively removing the image from the recipe.
    @MainActor
    func clearImage() {
        data = nil
    }
    
    var isUpDating: Bool { recipe != nil }
    
    /// Determines if the generate recipe button should be disabled.
    /// - The form is disabled if the title is empty.
    var isDisabled: Bool { title.isEmpty }
}
