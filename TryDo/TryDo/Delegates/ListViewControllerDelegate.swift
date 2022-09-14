import UIKit

protocol ListViewControllerDelegate: AnyObject {
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    )
}
