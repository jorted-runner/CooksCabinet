//
//  RecipeListView.swift
//  CooksCabinet
//
//  Created by Danny Ellis on 2/12/25.
//
//  This file defines the `RecipeListView`, which displays a list of saved recipes.
//  Users can navigate to recipe details, add new recipes, or delete existing ones.
//

import SwiftUI
import SwiftData

/// `RecipeListView` displays a list of saved recipes.
/// - Fetches recipes from the database using `@Query`.
/// - Supports navigation to recipe details.
/// - Allows users to add new recipes or delete existing ones.
/// - Uses `NavigationStack` for structured navigation.
struct RecipeListView: View {
    /// Fetches and sorts recipes alphabetically by title from the data model.
    @Query(sort: \RecipeModel.title) var recipes: [RecipeModel]
    @Environment(\.modelContext) private var modelContext

    /// Tracks the form state for adding a new recipe.
    @State private var formType: ModelFormType?
    var body: some View {
        NavigationStack {
            Group {
                if recipes.isEmpty {
                    // Display a placeholder view when no recipes are found.
                    ContentUnavailableView(
                        "No Recipes Found",
                        systemImage: "exclamationmark.circle"
                    )
                } else {
                    // Display a list of saved recipes.
                    List(recipes) { recipe in
                        NavigationLink(value: recipe) {
                            HStack {
                                Image(
                                    uiImage: recipe.image == nil ? Constants.placeholder : recipe.image!).resizable().scaledToFill().frame(
                                        width: 50,
                                        height: 50
                                    ).clipShape(
                                        RoundedRectangle(
                                            cornerRadius: 12
                                        )
                                    )
                                    .padding(.trailing)
                                VStack {
                                    Text(recipe.title)
                                        .font(.title)
                                    Text(recipe.recipeDescription)
                                        .font(.caption)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    modelContext.delete(recipe)
                                    try? modelContext.save()
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                        .listStyle(.plain)
                    }.refreshable {
                        try? modelContext.save() // Ensure updates are committed
                    }
                }
            }
            .navigationDestination(for: RecipeModel.self) { recipe in
                RecipeView(recipe: recipe)
            }
            .navigationTitle(Text("Cooks Cabient"))
            .toolbar {
                Button {
                    formType = .new
                }label: {
                    Image(systemName: "plus.circle.fill")
                }
                .sheet(item: $formType) { $0 }
            }
        }
    }
}

#Preview {
    RecipeListView()
        .modelContainer(RecipeModel.preview)
}
