import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataStore: GroceryDataStore
    @State private var showingAddItem = false
    @State private var showingCompleted = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    ForEach(dataStore.items) { item in
                        ItemRow(item: item)
                    }
                    .onMove { source, destination in
                        Task {
                            await dataStore.moveItems(from: source, to: destination)
                        }
                    }
                    .onDelete { indexSet in
                        Task {
                            for index in indexSet {
                                await dataStore.deleteItem(dataStore.items[index])
                            }
                        }
                    }
                }
                .listStyle(.plain)

                HStack(spacing: 16) {
                    Button(action: { showingCompleted = true }) {
                        Label("Browse", systemImage: "clock.arrow.circlepath")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(action: { showingAddItem = true }) {
                        Label("Add Item", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Grocery List")
            .toolbar {
                EditButton()
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView()
            }
            .sheet(isPresented: $showingCompleted) {
                CompletedItemsView()
            }
        }
    }
}

struct ItemRow: View {
    @EnvironmentObject var dataStore: GroceryDataStore
    let item: GroceryItem
    @State private var showingEdit = false

    var body: some View {
        HStack {
            Button(action: {
                Task {
                    await dataStore.toggleItem(item)
                }
            }) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isChecked ? .green : .gray)
                    .imageScale(.large)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)

                if !item.store.isEmpty {
                    Text(item.store)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showingEdit = true
        }
        .sheet(isPresented: $showingEdit) {
            EditItemView(item: item)
        }
    }
}
