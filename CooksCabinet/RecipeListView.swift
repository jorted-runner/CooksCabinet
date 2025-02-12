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
    var body: some View {
        NavigationStack {
            Group {
                if recipes.isEmpty {
                    ContentUnavailableView(
                        "No Recipes Found",
                        systemImage: "exclamationmark.circle"
                    )
                }
            }
        }
    }
}

#Preview {
    RecipeListView()
}
