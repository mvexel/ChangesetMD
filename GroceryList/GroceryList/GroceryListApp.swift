import SwiftUI

@main
struct GroceryListApp: App {
    @StateObject private var dataStore = GroceryDataStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
        }
    }
}
