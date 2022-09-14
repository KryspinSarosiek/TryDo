import Foundation

public final class DataModel {

    // MARK: - Properties

    var lists: [List] = []

    var indexOfSelectedList: Int {
        get {
            return UserDefaults.standard.integer(
                forKey: "ListIndex")
        } set {
            UserDefaults.standard.set(
                newValue,
                forKey: "ListIndex")
        }
    }

    // MARK: - Initialiser

    init() {
        loadLists()
        registerDefaults()
        handleFirstTime()
    }

    // MARK: - Helper Methods

    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(
            for: .documentDirectory,
               in: .userDomainMask)
        return paths[0]
    }

    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Lists.plist")
    }

    func saveLists() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(lists)
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        } catch {
            print("Error encoding list array: \(error.localizedDescription)")
        }
    }

    func loadLists() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
                lists = try decoder.decode([List].self, from: data)
            } catch {
                print("Error decoding list array: \(error.localizedDescription)")
            }
        }
    }

    func registerDefaults() {
        let dictionary: [String: Any] = [
            "ListIndex": -1,
            "FirstTime": true
        ]
        UserDefaults.standard.register(defaults: dictionary)
    }

    func handleFirstTime() {
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        if firstTime {
            let list = List(name: "List")
            lists.append(list)
            indexOfSelectedList = 0
            userDefaults.set(false, forKey: "FirstTime")
        }
    }

    static func nextListItemID() -> Int {
        let userDefaults = UserDefaults.standard
        let itemID = userDefaults.integer(forKey: "ListItemID")
        userDefaults.set(itemID + 1, forKey: "ListItemID")
        return itemID
    }
}
