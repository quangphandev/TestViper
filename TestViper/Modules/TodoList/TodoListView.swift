//
//  TodoListViewController.swift
//  TestViper
//
//  ╔══════════════════════════════════════════╗
//  ║  VIPER Layer: VIEW                       ║
//  ╚══════════════════════════════════════════╝
//

import UIKit

// MARK: - TodoListViewController

final class TodoListViewController: UIViewController {

    var presenter: TodoListPresenterInput?

    // MARK: - UI Components

    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Tìm todo..."
        sc.searchBar.tintColor = AppTheme.Color.primary
        return sc
    }()

    private lazy var filterSegmentedControl: UISegmentedControl = {
        let items = FilterType.allCases.map { $0.rawValue }
        let sc = UISegmentedControl(items: items)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = AppTheme.Color.primary
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: AppTheme.Color.textSecondary], for: .normal)
        sc.backgroundColor = AppTheme.Color.surfaceElevated
        sc.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        sc.accessibilityIdentifier = "filterSegmentedControl"
        return sc
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(TodoCell.self, forCellReuseIdentifier: TodoCell.reuseId)
        tv.dataSource = self
        tv.delegate = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 88
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tv.accessibilityIdentifier = "todoListTableView"
        return tv
    }()

    private lazy var inputTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.returnKeyType = .done
        tf.delegate = self
        tf.clearButtonMode = .whileEditing
        tf.applyThemedStyle(placeholder: "Nhập todo mới...")
        tf.accessibilityIdentifier = "todoInputTextField"
        return tf
    }()

    private lazy var addButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        btn.accessibilityIdentifier = "addTodoButton"
        btn.accessibilityLabel = "Thêm todo"
        return btn
    }()

    private lazy var inputBarView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppTheme.Color.surface
        v.layer.cornerRadius = AppTheme.Radius.large
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.applyShadow(AppTheme.Shadow.card)
        return v
    }()

    private lazy var inputStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [inputTextField, addButton])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = AppTheme.Spacing.sm
        sv.alignment = .center
        return sv
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.hidesWhenStopped = true
        ai.color = AppTheme.Color.primaryLight
        return ai
    }()

    private lazy var emptyStateView: EmptyStateView = {
        let v = EmptyStateView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        v.accessibilityIdentifier = "emptyStateView"
        return v
    }()

    // MARK: - State

    private var viewModels: [TodoViewModel] = []
    private var inputBarBottomConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        setupTapToDismissKeyboard()
        presenter?.viewDidLoad()
    }

    /// ✅ Bug Fix: refresh khi quay lại từ Detail screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addButton.layer.sublayers?
            .compactMap { $0 as? CAGradientLayer }
            .forEach { $0.frame = addButton.bounds }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = AppTheme.Color.background
        setupNavigationBar()

        view.addSubview(filterSegmentedControl)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(inputBarView)
        inputBarView.addSubview(inputStackView)
        view.addSubview(activityIndicator)

        setupConstraints()
        setupAddButtonStyle()
    }

    private func setupNavigationBar() {
        title = "My Todos"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [
            .foregroundColor: AppTheme.Color.textPrimary,
            .font: AppTheme.Typography.largeTitle
        ]
        appearance.titleTextAttributes = [.foregroundColor: AppTheme.Color.textPrimary]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = AppTheme.Color.primary
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        inputBarBottomConstraint = inputBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([
            // Filter segmented control dưới nav bar
            filterSegmentedControl.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: AppTheme.Spacing.sm),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppTheme.Spacing.md),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppTheme.Spacing.md),
            filterSegmentedControl.heightAnchor.constraint(equalToConstant: 32),

            // TableView
            tableView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: AppTheme.Spacing.sm),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputBarView.topAnchor),

            // Empty state
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppTheme.Spacing.xl),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppTheme.Spacing.xl),

            // Input bar
            inputBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBarBottomConstraint,

            inputStackView.topAnchor.constraint(equalTo: inputBarView.topAnchor, constant: AppTheme.Spacing.md),
            inputStackView.leadingAnchor.constraint(equalTo: inputBarView.leadingAnchor, constant: AppTheme.Spacing.md),
            inputStackView.trailingAnchor.constraint(equalTo: inputBarView.trailingAnchor, constant: -AppTheme.Spacing.md),
            inputStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -AppTheme.Spacing.sm),
            inputStackView.heightAnchor.constraint(equalToConstant: 48),

            addButton.widthAnchor.constraint(equalToConstant: 48),
            addButton.heightAnchor.constraint(equalToConstant: 48),
            inputTextField.heightAnchor.constraint(equalToConstant: 46),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupAddButtonStyle() {
        addButton.layer.cornerRadius = 24
        addButton.layer.masksToBounds = true
        addButton.applyGradient(
            colors: [AppTheme.Color.primary, AppTheme.Color.gradientBottom],
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: 1, y: 1),
            cornerRadius: 24
        )
    }

    // MARK: - Empty State

    private func updateEmptyState() {
        let isEmpty = viewModels.isEmpty
        UIView.animate(withDuration: AppTheme.Animation.quick) {
            self.emptyStateView.isHidden = !isEmpty
            self.tableView.alpha = isEmpty ? 0 : 1
        }
    }

    // MARK: - Keyboard

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func setupTapToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        inputBarBottomConstraint.constant = -frame.height
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        inputBarBottomConstraint.constant = 0
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    // MARK: - Actions

    @objc private func didTapAdd() {
        addButton.animateTap()
        presenter?.didTapAddTodo(title: inputTextField.text ?? "")
        inputTextField.text = ""
        inputTextField.resignFirstResponder()
    }

    @objc private func filterChanged() {
        let filter = FilterType.allCases[filterSegmentedControl.selectedSegmentIndex]
        presenter?.didSelectFilter(filter)
    }

    // MARK: - Edit Alert

    private func showEditAlert(at index: Int) {
        guard index < viewModels.count else { return }
        let currentTitle = viewModels[index].title
        let alert = UIAlertController(title: "Sửa todo", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.text = currentTitle
            tf.clearButtonMode = .whileEditing
            tf.autocapitalizationType = .sentences
        }
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        alert.addAction(UIAlertAction(title: "Lưu", style: .default) { [weak self] _ in
            let newTitle = alert.textFields?.first?.text ?? ""
            self?.presenter?.didEditTodo(at: index, newTitle: newTitle)
        })
        present(alert, animated: true)
    }
}

// MARK: - TodoListPresenterOutput

extension TodoListViewController: TodoListPresenterOutput {

    func displayTodos(_ viewModels: [TodoViewModel]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.viewModels = viewModels
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            self.updateEmptyState()
        }
    }

    func displayError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let alert = UIAlertController(title: "Lỗi", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    func displayLoading(_ isLoading: Bool) {
        DispatchQueue.main.async { [weak self] in
            isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
        }
    }
}

// MARK: - UITableViewDataSource

extension TodoListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseId, for: indexPath) as? TodoCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TodoListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.didSelectTodo(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            self?.presenter?.didTapDeleteTodo(at: indexPath.row)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = AppTheme.Color.danger

        let editAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            self?.showEditAlert(at: indexPath.row)
            completion(true)
        }
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = AppTheme.Color.primary

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let isCompleted = viewModels[indexPath.row].isCompleted
        let action = UIContextualAction(style: .normal, title: isCompleted ? "Bỏ xong" : "Xong") { [weak self] _, _, completion in
            self?.presenter?.didToggleComplete(at: indexPath.row)
            completion(true)
        }
        action.backgroundColor = isCompleted ? AppTheme.Color.warning : AppTheme.Color.success
        action.image = UIImage(systemName: isCompleted ? "arrow.uturn.backward.circle" : "checkmark.circle.fill")
        return UISwipeActionsConfiguration(actions: [action])
    }
}

// MARK: - UITextFieldDelegate

extension TodoListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { didTapAdd(); return true }
    func textFieldDidBeginEditing(_ textField: UITextField) { textField.applyFocusedStyle() }
    func textFieldDidEndEditing(_ textField: UITextField) { textField.applyUnfocusedStyle() }
}

// MARK: - UISearchResultsUpdating

extension TodoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        presenter?.didSearch(query: searchController.searchBar.text ?? "")
    }
}

// MARK: - EmptyStateView

final class EmptyStateView: UIView {

    private let iconLabel: UILabel = {
        let l = UILabel()
        l.text = "📋"; l.font = .systemFont(ofSize: 56)
        l.textAlignment = .center; l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Chưa có todo nào"
        l.font = AppTheme.Typography.headline
        l.textColor = AppTheme.Color.textPrimary
        l.textAlignment = .center; l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Thêm việc đầu tiên của bạn\nvào ô bên dưới nhé! 🚀"
        l.font = AppTheme.Typography.body
        l.textColor = AppTheme.Color.textSecondary
        l.textAlignment = .center; l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let sv = UIStackView(arrangedSubviews: [iconLabel, titleLabel, subtitleLabel])
        sv.axis = .vertical; sv.alignment = .center
        sv.spacing = AppTheme.Spacing.sm; sv.translatesAutoresizingMaskIntoConstraints = false
        sv.setCustomSpacing(AppTheme.Spacing.md, after: iconLabel)
        addSubview(sv)
        NSLayoutConstraint.activate([
            sv.topAnchor.constraint(equalTo: topAnchor),
            sv.leadingAnchor.constraint(equalTo: leadingAnchor),
            sv.trailingAnchor.constraint(equalTo: trailingAnchor),
            sv.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - TodoCell

final class TodoCell: UITableViewCell {

    static let reuseId = "TodoCell"

    // MARK: - UI

    /// Left color bar theo priority
    private let priorityBar: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 2
        return v
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.applyCardStyle()
        return v
    }()

    private let statusIconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = AppTheme.Typography.title
        l.textColor = AppTheme.Color.textPrimary
        l.numberOfLines = 2; l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.font = AppTheme.Typography.caption
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dueDateLabel: UILabel = {
        let l = UILabel()
        l.font = AppTheme.Typography.footnote
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = AppTheme.Typography.footnote
        l.textColor = AppTheme.Color.textTertiary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var textStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, statusLabel, dueDateLabel, dateLabel])
        sv.axis = .vertical; sv.spacing = AppTheme.Spacing.xs
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(priorityBar)
        cardView.addSubview(statusIconView)
        cardView.addSubview(textStackView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppTheme.Spacing.xs),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppTheme.Spacing.md),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppTheme.Spacing.md),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppTheme.Spacing.xs),

            // Priority bar bên trái card
            priorityBar.topAnchor.constraint(equalTo: cardView.topAnchor, constant: AppTheme.Spacing.sm),
            priorityBar.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: AppTheme.Spacing.sm),
            priorityBar.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -AppTheme.Spacing.sm),
            priorityBar.widthAnchor.constraint(equalToConstant: 4),

            // Status icon
            statusIconView.leadingAnchor.constraint(equalTo: priorityBar.trailingAnchor, constant: AppTheme.Spacing.sm),
            statusIconView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            statusIconView.widthAnchor.constraint(equalToConstant: 26),
            statusIconView.heightAnchor.constraint(equalToConstant: 26),

            // Text stack
            textStackView.leadingAnchor.constraint(equalTo: statusIconView.trailingAnchor, constant: AppTheme.Spacing.sm),
            textStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -AppTheme.Spacing.md),
            textStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: AppTheme.Spacing.md),
            textStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -AppTheme.Spacing.md),
        ])
    }

    // MARK: - Configure

    func configure(with vm: TodoViewModel) {
        // Priority bar
        priorityBar.backgroundColor = vm.priorityColor

        // Status icon
        statusIconView.image = UIImage(systemName: vm.isCompleted ? "checkmark.circle.fill" : "circle")
        statusIconView.tintColor = vm.isCompleted ? AppTheme.Color.success : AppTheme.Color.textTertiary

        // Title (strikethrough nếu completed)
        titleLabel.text = vm.title
        titleLabel.applyStrikethrough(vm.isCompleted)

        // Status
        statusLabel.text = vm.statusText
        statusLabel.textColor = vm.statusColor

        // Due date (ẩn nếu không có)
        if let dueDateText = vm.dueDateText {
            dueDateLabel.text = dueDateText
            dueDateLabel.textColor = vm.isOverdue ? AppTheme.Color.danger : AppTheme.Color.textSecondary
            dueDateLabel.isHidden = false
        } else {
            dueDateLabel.isHidden = true
        }

        // Created date
        dateLabel.text = vm.dateText

        // Card bg
        cardView.backgroundColor = vm.isCompleted ? AppTheme.Color.surfaceElevated : AppTheme.Color.surface

        accessibilityIdentifier = "todoCell_\(vm.id)"
    }

    // MARK: - Highlight

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: AppTheme.Animation.quick) {
            self.cardView.transform = highlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
        }
    }
}
