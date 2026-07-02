//
//  TodoDetailProtocols.swift
//  TestViper
//
//  Protocols cho module TodoDetail.
//  Module này đơn giản hơn TodoList — chỉ hiển thị, không edit.
//

import UIKit

// MARK: - View → Presenter
protocol TodoDetailPresenterInput: AnyObject {
    func viewDidLoad()
}

// MARK: - Presenter → View
protocol TodoDetailPresenterOutput: AnyObject {
    func displayTodo(title: String, status: String, statusColor: UIColor, date: String)
}

// MARK: - Presenter → Interactor
protocol TodoDetailInteractorInput: AnyObject {
    func fetchTodo()
}

// MARK: - Interactor → Presenter
protocol TodoDetailInteractorOutput: AnyObject {
    func didFetchTodo(_ item: TodoItem)
}

// MARK: - Router
protocol TodoDetailRouterInput: AnyObject {
    static func createModule(with item: TodoItem) -> UIViewController
}
