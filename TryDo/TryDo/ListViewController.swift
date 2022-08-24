import UIKit
import ExtenSwift

class ListViewController: UIViewController {

    private let cellIdentifier = "cell"

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        registerTableViewCell()
    }

    private func registerTableViewCell() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    private func configureViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.pinToSuperviewSafeArea()
    }

}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // using 100 rows as placeholder
        // number of rows will be determined by the number of elements in managed object array
        100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = "Row: \(indexPath.row)"
        return cell
    }


}
