import UIKit

protocol ListDetailViewControllerDelegate: AnyObject {

    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController)

    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding list: List)

    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing list: List)
}
