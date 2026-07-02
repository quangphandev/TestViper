//
//  TodoListViewController.swift
//  TestViper
//
//  ╔══════════════════════════════════════════╗
//  ║  VIPER Layer: VIEW                       ║
//  ╚══════════════════════════════════════════╝
//
//  View là layer "ngu" nhất trong VIPER (dumb view / passive view).
//  Quy tắc:
//    ✅ Chỉ render UI theo lệnh từ Presenter
//    ✅ Forward tất cả user action → Presenter (không tự xử lý)
//    ✅ KHÔNG có business logic, KHÔNG có formatting logic
//    ✅ KHÔNG gọi trực tiếp Interactor
//    ✅ Giữ strong reference đến Presenter (owner)
//
//  UIKit code (tableView.reloadData, layout...) sống ở đây.
//  Đây cũng là lý do View khó unit test → test bằng UI Test hoặc snapshot.
//

import UIKit

// MARK: - TodoListViewController

final class TodoListViewController: UIViewController {

    // Strong reference — View sở hữu Presenter
    var presenter: TodoListPresenterInput?

    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(TodoCell.self, forCellReuseIdentifier: TodoCell.reuseId)
        tv.dataSource = self
        tv.delegate = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 72
        return tv
    }()

    private lazy var inputTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Nhập todo mới..."
        tf.borderStyle = .roundedRect
        tf.returnKeyType = .done
        tf.delegate = self
        tf.clearButtonMode = .whileEditing
        return tf
    }()

    private lazy var addButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Thêm"
        config.cornerStyle = .medium
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        return btn
    }()

    private lazy var inputStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [inputTextField, addButton])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        return sv
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.hidesWhenStopped = true
        return ai
    }()

    // MARK: - Data Source (chỉ ViewModels — không có Entity ở View)

    private var viewModels: [TodoViewModel] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // ✅ View thông báo Presenter mình đã sẵn sàng
        // KHÔNG tự fetch data — delegate cho Presenter
        presenter?.viewDidLoad()
    }

    // MARK: - Setup UI

    private func setupUI() {
        title = "My Todos 📋"
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        view.addSubview(tableView)
        view.addSubview(inputStackView)
        view.addSubview(activityIndicator)

        setupConstraints()
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // Input bar ở bottom
            inputStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -12),
            inputStackView.heightAnchor.constraint(equalToConstant: 44),

            // Add button có width cố định
            addButton.widthAnchor.constraint(equalToConstant: 72),

            // TableView fill phần còn lại
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputStackView.topAnchor, constant: -8),

            // Activity Indicator ở giữa
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    // MARK: - Actions

    @objc private func didTapAdd() {
        let title = inputTextField.text ?? ""
        // ✅ Delegate cho Presenter — không tự validate
        presenter?.didTapAddTodo(title: title)
        inputTextField.text = ""
        inputTextField.resignFirstResponder()
    }
}

// MARK: - TodoListPresenterOutput (Presenter → View)

extension TodoListViewController: TodoListPresenterOutput {

    func displayTodos(_ viewModels: [TodoViewModel]) {
        self.viewModels = viewModels
        // Phải reload trên main thread (UIKit rule)
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    func displayError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Lỗi", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

    func displayLoading(_ isLoading: Bool) {
        DispatchQueue.main.async { [weak self] in
            if isLoading {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension TodoListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TodoCell.reuseId,
            for: indexPath
        ) as? TodoCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }

    // Swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // ✅ Delegate xoá cho Presenter — không tự xoá khỏi array
            presenter?.didTapDeleteTodo(at: indexPath.row)
        }
    }
}

// MARK: - UITableViewDelegate

extension TodoListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // ✅ Delegate navigate cho Presenter
        presenter?.didSelectTodo(at: indexPath.row)
    }

    // Leading swipe: toggle complete
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Toggle") { [weak self] _, _, completion in
            self?.presenter?.didToggleComplete(at: indexPath.row)
            completion(true)
        }
        action.backgroundColor = .systemBlue
        action.image = UIImage(systemName: "checkmark.circle")
        return UISwipeActionsConfiguration(actions: [action])
    }
}

// MARK: - UITextFieldDelegate

extension TodoListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapAdd()
        return true
    }
}

// MARK: - TodoCell

/// Custom cell để hiển thị TodoViewModel
final class TodoCell: UITableViewCell {

    static let reuseId = "TodoCell"

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .medium)
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .light)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, statusLabel, dateLabel])
        sv.axis = .vertical
        sv.spacing = 4
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    /// View nhận ViewModel (đã format) — không nhận Entity
    func configure(with viewModel: TodoViewModel) {
        titleLabel.text = viewModel.title
        statusLabel.text = viewModel.statusText
        statusLabel.textColor = viewModel.statusColor
        dateLabel.text = viewModel.dateText
    }
}
