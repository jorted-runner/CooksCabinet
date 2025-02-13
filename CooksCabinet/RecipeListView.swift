//
//  RecipeListView.swift
//  CooksCabinet
//
//  Created by Danny Ellis on 2/12/25.
//

import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query(sort: \RecipeModel.title) var recipes: [RecipeModel]
    @Environment(\.modelContext) private var modelContext
//    @State private var formType: ModelFormType?
    var body: some View {
        NavigationStack {
            Group {
                if recipes.isEmpty {
                    ContentUnavailableView(
                        "No Recipes Found",
                        systemImage: "exclamationmark.circle"
                    )
                } else {
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
                    }
                }
            }
            .navigationDestination(for: RecipeModel.self) { recipe in
                RecipeView(recipe: recipe)
            }
            .navigationTitle(Text("Cooks Cabient"))
            .toolbar {
                Button {
//                    formType = .new
                }label: {
                    Image(systemName: "plus.circle.fill")
                }
//                .sheet(item: $formType) { $0 }
            }
        }
    }
}

#Preview {
    RecipeListView()
        .modelContainer(RecipeModel.preview)
}
