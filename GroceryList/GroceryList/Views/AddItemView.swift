import SwiftUI

struct AddItemView: View {
    @EnvironmentObject var dataStore: GroceryDataStore
    @Environment(\.dismiss) var dismiss
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
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            let item = GroceryItem(name: itemName, store: storeName)
                            await dataStore.addItem(item)
                            dismiss()
                        }
                    }
                    .disabled(itemName.isEmpty)
                }
            }
        }
    }
}
