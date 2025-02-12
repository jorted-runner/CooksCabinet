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
    var ingredients: [IngredientModel] = []
    var instructions: [String] = []
    var image: UIImage? {
        if let data {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
    
    init(title: String, ingredients: [IngredientModel] = [], instructions: [String] = [], imageData: Data? = nil) {
        self.title = title
        self.data = imageData
        self.ingredients = ingredients
        self.instructions = instructions
    }
    
}

extension RecipeModel {
    
    @MainActor
    static var recipe: ModelContainer {
        let container = try! ModelContainer(
            for: RecipeModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        var recipes: [RecipeModel] {
            [
                .init(title: "Recipe 1"),
                .init(title: "Recipe 2"),
                .init(title: "Recipe 3")
            ]
        }
        
        recipes.forEach {
            container.mainContext.insert($0)
        }
        
        return container
    }
}
