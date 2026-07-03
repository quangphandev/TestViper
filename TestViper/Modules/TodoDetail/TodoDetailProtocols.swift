//
//  TodoDetailProtocols.swift
//  TestViper
//
//  Protocols cho module TodoDetail.
//

import UIKit

// MARK: - View → Presenter
protocol TodoDetailPresenterInput: AnyObject {
    func viewDidLoad()
    func didTapToggleComplete()
    func didChangePriority(_ priority: Priority)
    func didSetDueDate(_ date: Date?)
}

// MARK: - Presenter → View
protocol TodoDetailPresenterOutput: AnyObject {
    func displayTodo(
        title: String,
        status: String,
        statusColor: UIColor,
        date: String,
        isCompleted: Bool,
        priority: Priority,
        dueDate: Date?
    )
}

// MARK: - Presenter → Interactor
protocol TodoDetailInteractorInput: AnyObject {
    func fetchTodo()
    func toggleComplete()
    func updatePriority(_ priority: Priority)
    func updateDueDate(_ date: Date?)
}

// MARK: - Interactor → Presenter
protocol TodoDetailInteractorOutput: AnyObject {
    func didFetchTodo(_ item: TodoItem)
    func didUpdateTodo(_ item: TodoItem)
}

// MARK: - Router
protocol TodoDetailRouterInput: AnyObject {
    /// ✅ Bug Fix: nhận shared repository từ TodoListRouter
    static func createModule(with item: TodoItem, repository: TodoRepositoryProtocol) -> UIViewController
}
