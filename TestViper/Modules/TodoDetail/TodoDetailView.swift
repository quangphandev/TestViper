//
//  TodoDetailViewController.swift
//  TestViper
//
//  ╔══════════════════════════════════════════╗
//  ║  VIPER Layer: VIEW (TodoDetail)          ║
//  ╚══════════════════════════════════════════╝
//
//  Màn hình chi tiết todo:
//  - Gradient header với title + icon
//  - Info card: status, priority (segmented), due date (inline picker), created date
//  - Toggle Complete button ở bottom
//

import UIKit

final class TodoDetailViewController: UIViewController {

    var presenter: TodoDetailPresenterInput?

    // MARK: - Header

    private let headerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let headerIconLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 52)
        l.textAlignment = .center
        l.text = "📌"
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppTheme.Typography.largeTitle
        l.textColor = .white
        l.numberOfLines = 0
        l.textAlignment = .center
        l.accessibilityIdentifier = "detailTitleLabel"
        return l
    }()

    // MARK: - Info Card

    private let infoCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.applyCardStyle()
        return v
    }()

    private let statusRow = InfoRowView(iconName: "flag.fill", label: "Trạng thái")
    private let priorityRow = PriorityRowView()
    private let dueDateRow = DueDateRowView()
    private let createdRow = InfoRowView(iconName: "calendar", label: "Tạo lúc")

    private lazy var infoStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            statusRow,
            makeSeparator(),
            priorityRow,
            makeSeparator(),
            dueDateRow,
            makeSeparator(),
            createdRow,
        ])
        sv.axis = .vertical
        sv.spacing = 0
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Toggle Button

    private lazy var toggleButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = AppTheme.Radius.button
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = AppTheme.Typography.button
        btn.addTarget(self, action: #selector(didTapToggle), for: .touchUpInside)
        btn.accessibilityIdentifier = "toggleCompleteButton"
        return btn
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Wire up child views' callbacks
        priorityRow.onPriorityChanged = { [weak self] priority in
            self?.presenter?.didChangePriority(priority)
        }
        dueDateRow.onDateChanged = { [weak self] date in
            self?.presenter?.didSetDueDate(date)
        }

        presenter?.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.updateGradientFrame()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "Chi tiết"
        view.backgroundColor = AppTheme.Color.background
        navigationController?.navigationBar.tintColor = AppTheme.Color.primary

        view.addSubview(headerView)
        headerView.addSubview(headerIconLabel)
        headerView.addSubview(titleLabel)
        view.addSubview(infoCard)
        infoCard.addSubview(infoStackView)
        view.addSubview(toggleButton)

        headerView.applyGradient(
            colors: [AppTheme.Color.gradientTop, AppTheme.Color.gradientBottom],
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: 1, y: 1)
        )

        [statusRow, priorityRow, dueDateRow, createdRow].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        setupConstraints()
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 260),

            headerIconLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: AppTheme.Spacing.lg),
            headerIconLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: headerIconLabel.bottomAnchor, constant: AppTheme.Spacing.sm),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: AppTheme.Spacing.lg),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -AppTheme.Spacing.lg),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: headerView.bottomAnchor, constant: -AppTheme.Spacing.lg),

            infoCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -AppTheme.Radius.large),
            infoCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppTheme.Spacing.md),
            infoCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppTheme.Spacing.md),

            infoStackView.topAnchor.constraint(equalTo: infoCard.topAnchor),
            infoStackView.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor),
            infoStackView.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor),
            infoStackView.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor),

            toggleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppTheme.Spacing.md),
            toggleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppTheme.Spacing.md),
            toggleButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -AppTheme.Spacing.lg),
            toggleButton.heightAnchor.constraint(equalToConstant: 54),
        ])
    }

    // MARK: - Actions

    @objc private func didTapToggle() {
        toggleButton.animateTap()
        presenter?.didTapToggleComplete()
    }

    // MARK: - Separator Helper

    private func makeSeparator() -> UIView {
        let v = UIView()
        v.backgroundColor = AppTheme.Color.separator
        v.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return v
    }
}

// MARK: - TodoDetailPresenterOutput

extension TodoDetailViewController: TodoDetailPresenterOutput {

    func displayTodo(
        title: String, status: String, statusColor: UIColor,
        date: String, isCompleted: Bool, priority: Priority, dueDate: Date?
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.titleLabel.text = title
            self.headerIconLabel.text = isCompleted ? "✅" : "📌"

            self.statusRow.setValue(status, color: statusColor)
            self.createdRow.setValue(date, color: AppTheme.Color.textSecondary)

            self.priorityRow.setPriority(priority)
            self.dueDateRow.setDueDate(dueDate)

            // Toggle button style
            if isCompleted {
                self.toggleButton.setTitle("↩︎ Đánh dấu chưa xong", for: .normal)
                self.toggleButton.setTitleColor(.white, for: .normal)
                self.toggleButton.backgroundColor = AppTheme.Color.warning
                self.toggleButton.layer.sublayers?.removeAll { $0 is CAGradientLayer }
            } else {
                self.toggleButton.setTitle("✓ Đánh dấu hoàn thành", for: .normal)
                self.toggleButton.setTitleColor(.white, for: .normal)
                self.toggleButton.applyGradient(
                    colors: [AppTheme.Color.success, UIColor(hex: "#16A34A")],
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: 1, y: 0),
                    cornerRadius: AppTheme.Radius.button
                )
            }
        }
    }
}

// MARK: - InfoRowView

final class InfoRowView: UIView {

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        iv.tintColor = AppTheme.Color.primary
        return iv
    }()

    private let headerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppTheme.Typography.footnote
        l.textColor = AppTheme.Color.textTertiary
        return l
    }()

    private let valueLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppTheme.Typography.body
        l.textColor = AppTheme.Color.textPrimary
        l.numberOfLines = 0
        return l
    }()

    init(iconName: String, label: String) {
        super.init(frame: .zero)
        iconView.image = UIImage(systemName: iconName)
        headerLabel.text = label
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        addSubview(iconView); addSubview(headerLabel); addSubview(valueLabel)
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppTheme.Spacing.md),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: AppTheme.Spacing.md),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            headerLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: AppTheme.Spacing.sm),
            headerLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppTheme.Spacing.md),

            valueLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: AppTheme.Spacing.xs),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppTheme.Spacing.md),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppTheme.Spacing.md),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -AppTheme.Spacing.md),
        ])
    }

    func setValue(_ text: String, color: UIColor) {
        valueLabel.text = text; valueLabel.textColor = color
    }
}

// MARK: - PriorityRowView

final class PriorityRowView: UIView {

    var onPriorityChanged: ((Priority) -> Void)?

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "chart.bar.fill")
        iv.tintColor = AppTheme.Color.primary
        iv.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        return iv
    }()

    private let headerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Ưu tiên"
        l.font = AppTheme.Typography.footnote
        l.textColor = AppTheme.Color.textTertiary
        return l
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let items = Priority.allCases.map { $0.shortText }
        let sc = UISegmentedControl(items: items)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentTintColor = AppTheme.Color.primary
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: AppTheme.Color.textSecondary], for: .normal)
        sc.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return sc
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(iconView); addSubview(headerLabel); addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppTheme.Spacing.md),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: AppTheme.Spacing.md),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            headerLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: AppTheme.Spacing.sm),
            headerLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            segmentedControl.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: AppTheme.Spacing.sm),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppTheme.Spacing.md),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppTheme.Spacing.md),
            segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -AppTheme.Spacing.md),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func setPriority(_ priority: Priority) {
        segmentedControl.selectedSegmentIndex = priority.segmentIndex
        segmentedControl.selectedSegmentTintColor = priority.color
    }

    @objc private func segmentChanged() {
        let priority = Priority.from(segmentIndex: segmentedControl.selectedSegmentIndex)
        segmentedControl.selectedSegmentTintColor = priority.color
        onPriorityChanged?(priority)
    }
}

// MARK: - DueDateRowView

final class DueDateRowView: UIView {

    var onDateChanged: ((Date?) -> Void)?

    private var currentDate: Date?
    private var isPickerVisible = false
    private var pickerHeightConstraint: NSLayoutConstraint!

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "clock.fill")
        iv.tintColor = AppTheme.Color.primary
        iv.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        return iv
    }()

    private let headerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Hạn chót"
        l.font = AppTheme.Typography.footnote
        l.textColor = AppTheme.Color.textTertiary
        return l
    }()

    private let valueLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Chưa đặt hạn"
        l.font = AppTheme.Typography.body
        l.textColor = AppTheme.Color.textTertiary
        return l
    }()

    private lazy var setButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Đặt hạn", for: .normal)
        btn.titleLabel?.font = AppTheme.Typography.caption
        btn.tintColor = AppTheme.Color.primary
        btn.addTarget(self, action: #selector(tappedSetButton), for: .touchUpInside)
        return btn
    }()

    private lazy var datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.translatesAutoresizingMaskIntoConstraints = false
        dp.datePickerMode = .dateAndTime
        dp.preferredDatePickerStyle = .compact
        dp.minimumDate = Date()
        dp.tintColor = AppTheme.Color.primary
        dp.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        return dp
    }()

    private lazy var clearButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Xóa hạn", for: .normal)
        btn.titleLabel?.font = AppTheme.Typography.caption
        btn.tintColor = AppTheme.Color.danger
        btn.addTarget(self, action: #selector(tappedClearButton), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()

    private lazy var pickerRow: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [datePicker, clearButton])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = AppTheme.Spacing.sm
        sv.alignment = .center
        sv.isHidden = true
        return sv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        addSubview(iconView)
        addSubview(headerLabel)
        addSubview(valueLabel)
        addSubview(setButton)
        addSubview(pickerRow)

        pickerHeightConstraint = pickerRow.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppTheme.Spacing.md),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: AppTheme.Spacing.md),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            headerLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: AppTheme.Spacing.sm),
            headerLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            setButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppTheme.Spacing.md),
            setButton.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            valueLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: AppTheme.Spacing.xs),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppTheme.Spacing.md),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppTheme.Spacing.md),

            pickerRow.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: AppTheme.Spacing.xs),
            pickerRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppTheme.Spacing.md),
            pickerRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppTheme.Spacing.md),
            pickerRow.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -AppTheme.Spacing.md),
        ])
    }

    func setDueDate(_ date: Date?) {
        currentDate = date
        if let date {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            valueLabel.text = formatter.string(from: date)
            valueLabel.textColor = date < Date() ? AppTheme.Color.danger : AppTheme.Color.textPrimary
            setButton.setTitle("Sửa hạn", for: .normal)
            pickerRow.isHidden = false
            clearButton.isHidden = false
            datePicker.date = date
        } else {
            valueLabel.text = "Chưa đặt hạn"
            valueLabel.textColor = AppTheme.Color.textTertiary
            setButton.setTitle("Đặt hạn", for: .normal)
            pickerRow.isHidden = true
            clearButton.isHidden = true
        }
    }

    @objc private func tappedSetButton() {
        // Set ngay với ngày hiện tại + 1 ngày nếu chưa có
        if currentDate == nil {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            datePicker.date = tomorrow
            onDateChanged?(tomorrow)
        } else {
            pickerRow.isHidden.toggle()
        }
    }

    @objc private func tappedClearButton() {
        onDateChanged?(nil)
    }

    @objc private func datePickerChanged() {
        onDateChanged?(datePicker.date)
    }
}
