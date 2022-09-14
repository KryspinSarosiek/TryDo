import UIKit

final class ListDetailViewController: UIViewController {

    private let cellIdentifier = ""
    private unowned let delegate: ListDetailViewControllerDelegate
    var listToEdit: List?

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Name of item..."
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        return textField
    }()


    init(delegate: ListDetailViewControllerDelegate, listToEdit: List? = nil) {
        self.delegate = delegate
        self.listToEdit = listToEdit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        textField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        configureViews()
        configureNavigationBar()
    }

    // MARK: - Private Methods

    private func configureViews() {
        view.addSubview(textField)
        textField.pinToSuperviewSafeArea(excludingEdges: [.bottom])
        textField.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    private func configureNavigationBar() {

        self.navigationItem.title = "Add List"

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(tappedCancel(_:))
        )

        self.navigationItem.rightBarButtonItem = {
            let someButton = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(tappedDone(_:))
            )
            someButton.isEnabled = false
            return someButton
        }()
        self.navigationItem.largeTitleDisplayMode = .never

        if let list = listToEdit {
            title = "Edit List"
            textField.text = list.name
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }

    @objc func tappedCancel(_ sender: Any) {
        delegate.listDetailViewControllerDidCancel(self)
    }

    @objc func tappedDone(_ sender: Any) {
        if let list = listToEdit {
            list.name = textField.text!
            delegate.listDetailViewController(self, didFinishEditing: list)
        } else {
            let list = List(name: textField.text!, items: [])
            delegate.listDetailViewController(self, didFinishAdding: list)
        }
    }

}

// MARK: - Extensions

extension ListDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField.text != nil else {
            return true
        }

        textField.resignFirstResponder()
        tappedDone(self)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textFieldIsEmpty = textField.text?.isEmpty else { return }

        if textFieldIsEmpty {
            return
        }
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        self.navigationItem.rightBarButtonItem?.isEnabled = !newText.isEmpty
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        return true
    }
}
