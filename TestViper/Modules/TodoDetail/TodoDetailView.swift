//
//  TodoDetailViewController.swift
//  TestViper
//
//  ╔══════════════════════════════════════════╗
//  ║  VIPER Layer: VIEW (TodoDetail)          ║
//  ╚══════════════════════════════════════════╝
//
//  View chi tiết — chỉ hiển thị thông tin của 1 todo item.
//  Minh hoạ cách View nhận formatted strings từ Presenter
//  thay vì tự format Date, tự tính status...
//

import UIKit

final class TodoDetailViewController: UIViewController {

    var presenter: TodoDetailPresenterInput?

    // MARK: - UI

    private let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 8
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 24, weight: .bold)
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.textAlignment = .center
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, statusLabel, dateLabel])
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "Chi tiết"
        view.backgroundColor = .systemBackground

        view.addSubview(containerView)
        containerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -32),
        ])
    }
}

// MARK: - TodoDetailPresenterOutput

extension TodoDetailViewController: TodoDetailPresenterOutput {
    func displayTodo(title: String, status: String, statusColor: UIColor, date: String) {
        DispatchQueue.main.async { [weak self] in
            self?.titleLabel.text = title
            self?.statusLabel.text = status
            self?.statusLabel.textColor = statusColor
            self?.dateLabel.text = "Tạo lúc: \(date)"
        }
    }
}
