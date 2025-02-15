//
//  ModelFormType.swift
//  CooksCabinet
//
//  Created by Danny Ellis on 2/13/25.
//
//  This file defines the `ModelFormType` enum, which represents different states
//  of the recipe form (creating a new recipe or updating an existing one).
//

import SwiftUI

enum ModelFormType: Identifiable, View {
    case new
    case update(RecipeModel)
    var id: String {
        String(describing: self)
    }
    
    /// Returns the appropriate form view based on the selected form type.
    var body: some View {
        switch self {
        case .new:
            /// Displays a blank `UpdateEditFormView` for creating a new recipe.
            UpdateEditFormView(vm: UpdateEditFormViewModel())
            
        case .update(let model):
            /// Displays an `UpdateEditFormView` with existing recipe data for editing.
            UpdateEditFormView(vm: UpdateEditFormViewModel(recipe: model))
        }
    }
}

