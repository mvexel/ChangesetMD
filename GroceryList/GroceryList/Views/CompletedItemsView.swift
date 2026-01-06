import SwiftUI

struct CompletedItemsView: View {
    @EnvironmentObject var dataStore: GroceryDataStore
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    var filteredItems: [GroceryItem] {
        if searchText.isEmpty {
            return dataStore.completedItems
        } else {
            return dataStore.completedItems.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.store.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredItems) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(.body)

                            HStack {
                                if !item.store.isEmpty {
                                    Text(item.store)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                if item.addCount > 1 {
                                    Text("• Added \(item.addCount) times")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Spacer()

                        Button(action: {
                            Task {
                                await dataStore.readdItem(item)
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .imageScale(.large)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onDelete { indexSet in
                    Task {
                        for index in indexSet {
                            await dataStore.deleteItem(filteredItems[index])
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search items")
            .navigationTitle("Previously Added")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
