import Foundation
import UserNotifications

final class ListItem: NSObject, Codable {
    var text: String = ""
    var checked: Bool = false
    var dueDate: Date = Date()
    var shouldRemind: Bool = false
    var itemID: Int = -1

    init(text: String, checked: Bool) {
        self.text = text
        self.checked = checked
    }

    override init() {
        super.init()
        itemID = DataModel.nextListItemID()
    }

    func toggleChecked() {
        checked.toggle()
    }

    func scheduleNotification() {
        removeNotification()
        if shouldRemind && dueDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "Reminder:"
            content.body = text
            content.sound = UNNotificationSound.default

            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: dueDate
            )

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "\(itemID)",
                content: content,
                trigger: trigger
            )
            let center = UNUserNotificationCenter.current()
            center.add(request)
            print("Scheduled: \(request) for itemID: \(itemID)")
        }
    }

    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(
            withIdentifiers: ["\(itemID)"]
        )
    }

    deinit {
        removeNotification()
    }
}
