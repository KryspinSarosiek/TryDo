import UIKit

class ItemDetailViewController: UIViewController {

    // MARK: - Properties

    private let cellIdentifier = "cell"
    private unowned let delegate: ItemDetailViewControllerDelegate
    private var itemToEdit: ListItem?

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

    private(set) lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        return datePicker
    }()


    private(set) lazy var shouldRemindSwitch: UISwitch = {
        let reminderSwitch = UISwitch()
        reminderSwitch.addTarget(
            self,
            action: #selector(shouldRemindToggled),
            for: .touchUpInside
        )
        return reminderSwitch
    }()

    private(set) lazy var reminderStack: UIStackView = {
        let label = UILabel()
        label.text = "Remind me"
        let stackView = UIStackView(arrangedSubviews: [label, shouldRemindSwitch])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private(set) lazy var dateStack: UIStackView = {
        let label = UILabel()
        label.text = "Due date"
        let stackView = UIStackView(arrangedSubviews: [label, datePicker])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private(set) lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textField, reminderStack, dateStack])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Initialisers

    init(delegate: ItemDetailViewControllerDelegate, itemToEdit: ListItem? = nil) {
        self.delegate = delegate
        self.itemToEdit = itemToEdit
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life-Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        configureNavigationBar()
    }

    // MARK: - Private Methods

    private func configureViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        stackView.pinToSuperviewSafeArea(excludingEdges: [.bottom])
        stackView.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        if let item = itemToEdit {
            title = "Edit Item"
            textField.text = item.text
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            shouldRemindSwitch.isOn = item.shouldRemind
            datePicker.date = item.dueDate
        }
    }

    private func configureNavigationBar() {

        self.navigationItem.title = "Add Item"

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
    }

    @objc func tappedCancel(_ sender: Any) {
        delegate.itemDetailViewControllerDidCancel(self)
    }

    @objc func tappedDone(_ sender: Any) {
        if let item = itemToEdit {
            item.text = textField.text!
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = datePicker.date
            item.scheduleNotification()
            delegate.itemDetailViewController(self, didFinishEditing: item)
        } else {
            let item = ListItem()
            item.text = textField.text!
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = datePicker.date
            item.scheduleNotification()
            delegate.itemDetailViewController(self, didFinishAdding: item)
        }
    }

    @objc func shouldRemindToggled(_ switchControl: UISwitch) {
        textField.resignFirstResponder()

        print("poopy poopy poopy poopy poopy")
        if switchControl.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { _, _ in
                // code
            }
        }
    }
}

// MARK: - Extensions

extension ItemDetailViewController: UITextFieldDelegate {

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
