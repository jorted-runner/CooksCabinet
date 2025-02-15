//
//  RecipeView.swift
//  CooksCabinet
//
//  Created by Danny Ellis on 2/13/25.
//
//  This file defines the `RecipeView`, which displays the details of a selected recipe.
//  Users can view recipe information, including title, description, image, ingredients, and instructions.
//  The view also allows users to edit or delete the recipe.
//

import SwiftUI
import SwiftData

/// `RecipeView` displays the details of a selected recipe.
/// - Shows recipe title, description, ingredients, and instructions.
/// - Displays the associated image or a placeholder if none exists.
/// - Allows users to edit or delete the recipe.
/// - Uses `ScrollView` for better readability of long content.
struct RecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var formType: ModelFormType?
    let recipe: RecipeModel
    var body: some View {
        ScrollView {
            VStack {
                Text(recipe.title)
                    .font(.largeTitle)
                Text(recipe.recipeDescription)
                    .font(.footnote)
                Image(uiImage: recipe.image == nil ? Constants.placeholder : recipe.image!)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
                Text("Ingredients").font(.title2)
                ForEach(recipe.ingredients, id: \.self) { ingredient in
                    Text("- \(ingredient)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                Text("Instructions").font(.title2)
                ForEach(Array(recipe.instructions.enumerated()), id: \.element) { index, instruction in
                    Text("\(index + 1). \(instruction)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack {
                    Button("Edit") {
                        formType = .update(recipe)
                    }
                    .sheet(item: $formType) { $0 }
                    Button("Delete", role: .destructive) {
                        modelContext.delete(recipe)
                        try? modelContext.save()
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .trailing)
                Spacer()
            }
            .padding()
            .navigationTitle("Recipe View")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let container = RecipeModel.preview
    let fetchDescriptor = FetchDescriptor<RecipeModel>()
    let recipe = try! container.mainContext.fetch(fetchDescriptor)[0]
    return NavigationStack {RecipeView(recipe: recipe)}
}
