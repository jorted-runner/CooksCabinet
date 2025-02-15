//
//  RecipeModel.swift
//  CooksCabinet
//
//  Created by Danny Ellis on 2/12/25.
//
//  This file defines the `RecipeModel` class, which represents a recipe in the application.
//  Each recipe contains a title, ingredients, instructions, an optional image, and a description.
//  The model uses `SwiftData` for persistence and supports external image storage.
//

import UIKit
import SwiftData

/// `RecipeModel` represents a recipe entry in the app.
/// - Stored using `SwiftData` for persistence.
/// - Includes a title, list of ingredients, instructions, a description, and an optional image.
/// - Uses `@Model` to enable automatic data persistence.
@Model
class RecipeModel {
    var title: String
    @Attribute(.externalStorage)
    var data: Data?
    var ingredients: [String] = []
    var instructions: [String] = []
    var recipeDescription: String
    var image: UIImage? {
        if let data {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
    
    init(
        title: String,
        ingredients: [String] = [],
        instructions: [String] = [],
        imageData: Data? = nil,
        recipeDescription: String
    ) {
        self.title = title
        self.data = imageData
        self.ingredients = ingredients
        self.instructions = instructions
        self.recipeDescription = recipeDescription
    }
    
}

extension RecipeModel {
    
    /// Provides a preview `ModelContainer` with sample recipe data.
    /// - This is used for SwiftUI previews and testing without modifying actual storage.
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(
            for: RecipeModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true) // Stores preview data in memory only
        )
        
        // Sample recipes for preview
        var recipes: [RecipeModel] {
            [
                .init(
                    title: "Recipe 1",
                    ingredients: ["1 cup flour"],
                    instructions: ["Mix flour with water."],
                    imageData: nil,
                    recipeDescription: "This is a test recipe"
                )
            ]
        }
        
        // Insert sample recipes into the in-memory database
        recipes.forEach {
            container.mainContext.insert($0)
        }
        
        return container
    }
}
