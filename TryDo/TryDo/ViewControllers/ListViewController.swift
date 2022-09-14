import UIKit
import ExtenSwift

final class ListViewController: UIViewController {

    private let cellIdentifier = "cell"
    private var list: List!
    private unowned var delegate: ListViewControllerDelegate
    var itemDetailViewController: ItemDetailViewController?

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    init(delegate: ListViewControllerDelegate, list: List) {
        self.delegate = delegate
        self.list = list
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        registerTableViewCell()
        configureNavigationBar()
        configureViews()

    }

    private func registerTableViewCell() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    private func configureViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.pinToSuperviewSafeArea()
    }

    func configureNavigationBar() {
        self.navigationItem.title = list.name
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.backBarButtonItem?.action = #selector(back(_:))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addItem)
        )
    }

    @objc func back(_ sender: Any) {
        guard let navigationController = navigationController else { return }
        delegate.navigationController(
            navigationController,
            willShow: navigationController.viewControllers[0],
            animated: true
        )
        navigationController.popViewController(animated: true)
    }

    @objc func addItem(_ sender: Any) {
        itemDetailViewController = ItemDetailViewController(delegate: self)
        guard let itemDetailViewController = itemDetailViewController else { return }
        navigationController?.pushViewController(itemDetailViewController, animated: true)
    }

}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    // tells table view how many rows to create based on the number of items in the data model.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.items.count
    }

    // tells the table view how to configure the cell for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.accessoryType = .detailButton
        let item = list.items[indexPath.row]
        configureText(for: cell, with: item)
        configureChecked(for: cell, with: item)
        return cell
    }

    // tells the table view that the accessory view's button has been tapped
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let item = list.items[indexPath.row]
        itemDetailViewController = ItemDetailViewController(delegate: self, itemToEdit: item)
        guard let itemDetailViewController = itemDetailViewController else { return }
        navigationController?.pushViewController(itemDetailViewController, animated: true)
    }

    // tells the table view how to reconfigure the cell for a row when the user taps said row.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let item = list.items[indexPath.row]
        item.checked.toggle()
        configureChecked(for: cell, with: item)
    }

    // tells the table view which row to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        list.items.remove(at: indexPath.row)
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }

    func configureChecked(for cell: UITableViewCell, with item: ListItem) {
        if item.checked {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: item.text)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.textLabel?.attributedText = attributeString
        } else {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: item.text)
            cell.textLabel?.attributedText = attributedString
        }
    }

    func configureText(for cell: UITableViewCell, with item: ListItem) {
        cell.textLabel?.text = item.text
    }

}

extension ListViewController: ItemDetailViewControllerDelegate {
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
        navigationController?.popViewController(animated: true)
        itemDetailViewController = nil
    }

    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ListItem) {
        // table view has n rows and items array has n items.
        let newRowIndex = list.items.count
        list.items.append(item)
        // table view still has n rows but items array now has n+1 items.
        // the item constant is declared in the ItemDetailViewController's objc func

        // the items array has had an item added, now the table view needs a new row.
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        // when you call tableView.insertRows(at:with:) thee table view makes a cell for
        // this new row by calling the tableView(_:cellForRowAt:) data source method.
        navigationController?.popViewController(animated: true)
        itemDetailViewController = nil
    }

    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ListItem) {
        if let index = list.items.firstIndex(of: item) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                configureText(for: cell, with: item)
            }
        }
        navigationController?.popViewController(animated: true)
        itemDetailViewController = nil
    }
}
