import Foundation
import CloudKit

struct GroceryItem: Identifiable, Codable {
    var id: String
    var name: String
    var isChecked: Bool
    var store: String
    var addCount: Int
    var sortOrder: Int
    var lastModified: Date

    init(id: String = UUID().uuidString, name: String, isChecked: Bool = false, store: String = "", addCount: Int = 1, sortOrder: Int = 0) {
        self.id = id
        self.name = name
        self.isChecked = isChecked
        self.store = store
        self.addCount = addCount
        self.sortOrder = sortOrder
        self.lastModified = Date()
    }

    // CloudKit conversion
    init?(from record: CKRecord) {
        guard let name = record["name"] as? String,
              let isChecked = record["isChecked"] as? Int,
              let store = record["store"] as? String,
              let addCount = record["addCount"] as? Int,
              let sortOrder = record["sortOrder"] as? Int,
              let lastModified = record["lastModified"] as? Date else {
            return nil
        }

        self.id = record.recordID.recordName
        self.name = name
        self.isChecked = isChecked == 1
        self.store = store
        self.addCount = addCount
        self.sortOrder = sortOrder
        self.lastModified = lastModified
    }

    func toRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: "GroceryItem", recordID: recordID)
        record["name"] = name as CKRecordValue
        record["isChecked"] = (isChecked ? 1 : 0) as CKRecordValue
        record["store"] = store as CKRecordValue
        record["addCount"] = addCount as CKRecordValue
        record["sortOrder"] = sortOrder as CKRecordValue
        record["lastModified"] = lastModified as CKRecordValue
        return record
    }
}
