import UIKit
import ExtenSwift

public final class AllListsViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: - Properties

    private let cellIdentifier = "cell"
    private var listViewController: ListViewController?
    private var listDetailViewController: ListDetailViewController?
    private var dataModel: DataModel!

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    // MARK: - Initialization

    public init(dataModel: DataModel) {
        super.init(nibName: nil, bundle: nil)
        self.dataModel = dataModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life-Cycle

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.backgroundColor = .systemBackground

        navigationController?.delegate = self
        pushListViewController()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        registerTableViewCell()
        configureNavigationBar()
        configureTableView()
    }

    // MARK: - Private Methods

    private func pushListViewController() {
        let index = dataModel.indexOfSelectedList
        if index >= 0 && index < dataModel.lists.count {
            let list = dataModel.lists[index]
            listViewController = ListViewController(delegate: self, list: list)
            guard let listViewController = listViewController else { return }
            navigationController?.pushViewController(listViewController, animated: true)
        }
    }

    private func registerTableViewCell() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    private func configureNavigationBar() {
        self.navigationItem.title = "All Lists"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addList)
        )
    }

    @objc private func addList(_ sender: Any) {
        listDetailViewController = ListDetailViewController(delegate: self)
        guard let listDetailViewController = listDetailViewController else { return }
        navigationController?.pushViewController(listDetailViewController, animated: true)

    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.pinToSuperviewSafeArea()
    }

}

// MARK: - Extensions

extension AllListsViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataModel.lists.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let list = dataModel.lists[indexPath.row]
        cell.textLabel?.text = list.name
        cell.accessoryType = .detailDisclosureButton
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataModel.indexOfSelectedList = indexPath.row
        let list = dataModel.lists[indexPath.row]
        listViewController = ListViewController(delegate: self, list: list)
        guard let listViewController = listViewController else { return }
        navigationController?.pushViewController(listViewController, animated: true)
    }

    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let list = dataModel.lists[indexPath.row]
        listDetailViewController = ListDetailViewController(delegate: self, listToEdit: list)
        guard let listDetailViewController = listDetailViewController else { return }
        navigationController?.pushViewController(listDetailViewController, animated: true)

    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        dataModel.lists[indexPath.row].items.removeAll()
        dataModel.lists.remove(at: indexPath.row)
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }

}

extension AllListsViewController: ListViewControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        if viewController === navigationController.viewControllers[0] {
            dataModel.indexOfSelectedList = -1
        }
    }
}

extension AllListsViewController: ListDetailViewControllerDelegate {

    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
        navigationController?.popViewController(animated: true)
        listDetailViewController = nil
    }

    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding list: List) {
        let newRowIndex = dataModel.lists.count
        dataModel.lists.append(list)

        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)

        navigationController?.popViewController(animated: true)
        listDetailViewController = nil
    }

    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing list: List) {
        if let index = dataModel.lists.firstIndex(of: list) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.textLabel!.text = list.name
            }
        }
        navigationController?.popViewController(animated: true)
        listDetailViewController = nil
    }
}
