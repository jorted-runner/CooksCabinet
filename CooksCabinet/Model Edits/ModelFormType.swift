//
//  ModelFormType.swift
//  CooksCabinet
//
//  Created by Danny Ellis on 2/13/25.
//

import SwiftUI

enum ModelFormType: Identifiable, View {
    case new
    case update(RecipeModel)
    var id: String {
        String(describing: self)
    }
    var body: some View {
        switch self {
        case .new:
            UpdateEditFormView(vm: UpdateEditFormViewModel())
        case .update(let model):
            UpdateEditFormView(vm: UpdateEditFormViewModel(recipe: model))
        }
    }
}

