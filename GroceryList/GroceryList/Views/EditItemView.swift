import SwiftUI

struct EditItemView: View {
    @EnvironmentObject var dataStore: GroceryDataStore
    @Environment(\.dismiss) var dismiss
    let item: GroceryItem
    @State private var itemName = ""
    @State private var storeName = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Item name", text: $itemName)
                        .autocapitalization(.words)

                    TextField("Store (optional)", text: $storeName)
                        .autocapitalization(.words)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            var updatedItem = item
                            updatedItem.name = itemName
                            updatedItem.store = storeName
                            updatedItem.lastModified = Date()
                            await dataStore.updateItem(updatedItem)
                            dismiss()
                        }
                    }
                    .disabled(itemName.isEmpty)
                }
            }
            .onAppear {
                itemName = item.name
                storeName = item.store
            }
        }
    }
}
