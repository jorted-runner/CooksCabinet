//
//  RecipeModel.swift
//  CooksCabinet
//
//  Created by Danny Ellis on 2/12/25.
//

import UIKit
import SwiftData

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
    
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(
            for: RecipeModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        var recipes: [RecipeModel] {
            [
                .init(
                    title: "Recipe 1",
                    ingredients: ["1 cup flower"],
                    instructions: ["Blow on the flower."],
                    imageData: nil,
                    recipeDescription: "This is a test recipe"
                ),
//                .init(title: "Recipe 2", ingredients: [IngredientModel(name: "Flower", quantity: "2 Cups")], instructions: ["Blow on the flower."], imageData: nil, recipeDescription: "This is a test recipe"),
//                .init(title: "Recipe 3", ingredients: [IngredientModel(name: "Flower", quantity: "3 Cups")], instructions: ["Blow on the flower."], imageData: nil, recipeDescription: "This is a test recipe")
            ]
        }
        
        recipes.forEach {
            container.mainContext.insert($0)
        }
        
        return container
    }
}
