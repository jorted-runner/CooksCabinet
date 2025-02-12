//
//  CooksCabinetApp.swift
//  CooksCabinet
//
//  Created by Danny Ellis on 2/12/25.
//

import SwiftUI

@main
struct CooksCabinetApp: App {
    var body: some Scene {
        WindowGroup {
            RecipeListView()
        }
        .modelContainer(for: RecipeModel.self)
    }
}
