import Foundation

final class List: NSObject, Codable {
    var name = ""
    var items: [ListItem]

    init(name: String, items: [ListItem] = []) {
        self.name = name
        self.items = items
    }
}
