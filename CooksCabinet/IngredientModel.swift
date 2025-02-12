//
//  IngredientModel.swift
//  CooksCabinet
//
//  Created by Danny Ellis on 2/12/25.
//

import SwiftData

@Model
class IngredientModel {
    var name: String
    var quantity: String
    
    init(name: String, quantity: String) {
        self.name = name
        self.quantity = quantity
    }
}
