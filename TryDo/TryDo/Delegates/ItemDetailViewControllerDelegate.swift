
protocol ItemDetailViewControllerDelegate: AnyObject {

    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController)

    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ListItem)

    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ListItem)
}
