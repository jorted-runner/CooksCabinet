//
//  RecipeView.swift
//  CooksCabinet
//
//  Created by Danny Ellis on 2/13/25.
//

import SwiftUI
import SwiftData

struct RecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var formType: ModelFormType?
    let recipe: RecipeModel
    var body: some View {
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
            List(recipe.ingredients) { ingredient in
                Text("- \(ingredient.quantity) \(ingredient.name)")
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

#Preview {
    let container = RecipeModel.preview
    let fetchDescriptor = FetchDescriptor<RecipeModel>()
    let recipe = try! container.mainContext.fetch(fetchDescriptor)[0]
    return NavigationStack {RecipeView(recipe: recipe)}
}
