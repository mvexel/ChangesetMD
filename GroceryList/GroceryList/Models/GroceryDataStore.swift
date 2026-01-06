import Foundation
import CloudKit
import Combine

@MainActor
class GroceryDataStore: ObservableObject {
    @Published var items: [GroceryItem] = []
    @Published var completedItems: [GroceryItem] = []

    private let container: CKContainer
    private let database: CKDatabase

    init() {
        container = CKContainer(identifier: "iCloud.com.grocerylist")
        database = container.privateCloudDatabase

        Task {
            await loadItems()
            setupSubscription()
        }
    }

    func loadItems() async {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "GroceryItem", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]

        do {
            let result = try await database.records(matching: query)
            let records = result.matchResults.compactMap { try? $0.1.get() }
            let loadedItems = records.compactMap { GroceryItem(from: $0) }

            self.items = loadedItems.filter { !$0.isChecked }.sorted { $0.sortOrder < $1.sortOrder }
            self.completedItems = loadedItems.filter { $0.isChecked }.sorted { $0.addCount > $1.addCount }
        } catch {
            print("Error loading items: \(error)")
        }
    }

    func addItem(_ item: GroceryItem) async {
        var newItem = item
        newItem.sortOrder = items.count

        let record = newItem.toRecord()
        do {
            _ = try await database.save(record)
            items.append(newItem)
        } catch {
            print("Error saving item: \(error)")
        }
    }

    func toggleItem(_ item: GroceryItem) async {
        guard let index = items.firstIndex(where: { $0.id == item.id }) ?? completedItems.firstIndex(where: { $0.id == item.id }) else { return }

        var updatedItem = items.contains(where: { $0.id == item.id }) ? items[index] : completedItems[index]
        updatedItem.isChecked.toggle()
        updatedItem.lastModified = Date()

        let record = updatedItem.toRecord()
        do {
            _ = try await database.save(record)

            if updatedItem.isChecked {
                items.removeAll { $0.id == item.id }
                completedItems.append(updatedItem)
                completedItems.sort { $0.addCount > $1.addCount }
            } else {
                completedItems.removeAll { $0.id == item.id }
                items.append(updatedItem)
            }
        } catch {
            print("Error toggling item: \(error)")
        }
    }

    func readdItem(_ item: GroceryItem) async {
        guard let index = completedItems.firstIndex(where: { $0.id == item.id }) else { return }

        var updatedItem = completedItems[index]
        updatedItem.isChecked = false
        updatedItem.addCount += 1
        updatedItem.sortOrder = items.count
        updatedItem.lastModified = Date()

        let record = updatedItem.toRecord()
        do {
            _ = try await database.save(record)

            completedItems.remove(at: index)
            items.append(updatedItem)
        } catch {
            print("Error re-adding item: \(error)")
        }
    }

    func updateItem(_ item: GroceryItem) async {
        let record = item.toRecord()
        do {
            _ = try await database.save(record)

            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index] = item
            }
        } catch {
            print("Error updating item: \(error)")
        }
    }

    func deleteItem(_ item: GroceryItem) async {
        let recordID = CKRecord.ID(recordName: item.id)
        do {
            _ = try await database.deleteRecord(withID: recordID)
            items.removeAll { $0.id == item.id }
            completedItems.removeAll { $0.id == item.id }
        } catch {
            print("Error deleting item: \(error)")
        }
    }

    func moveItems(from source: IndexSet, to destination: Int) async {
        items.move(fromOffsets: source, toOffset: destination)

        for (index, item) in items.enumerated() {
            var updatedItem = item
            updatedItem.sortOrder = index
            items[index] = updatedItem
            await updateItem(updatedItem)
        }
    }

    private func setupSubscription() {
        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: "GroceryItem", predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion])

        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo

        database.save(subscription) { _, error in
            if let error = error {
                print("Subscription error: \(error)")
            }
        }
    }
}
