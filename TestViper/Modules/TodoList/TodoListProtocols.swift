//
//  TodoListProtocols.swift
//  TestViper
//
//  ╔══════════════════════════════════════════════════════════╗
//  ║  VIPER: PROTOCOL DEFINITIONS cho module TodoList         ║
//  ╚══════════════════════════════════════════════════════════╝
//

import UIKit

// MARK: - Filter Type

/// Loại filter cho danh sách todo
enum FilterType: String, CaseIterable {
    case all       = "Tất cả"
    case pending   = "Chưa xong"
    case completed = "Hoàn thành"
}

// MARK: - ViewModel

/// ViewModel là data đã được FORMAT sẵn để View hiển thị.
/// Presenter tạo ra ViewModel từ Entity (TodoItem).
struct TodoViewModel {
    let id: UUID
    let title: String

    // Status
    let statusText: String
    let statusColor: UIColor
    let isCompleted: Bool

    // Priority
    let priorityColor: UIColor
    let priorityText: String

    // Due date
    let dueDateText: String?   // nil nếu không có hạn
    let isOverdue: Bool

    // Created date
    let dateText: String
}

// MARK: - View → Presenter

/// Những gì View có thể "yêu cầu" Presenter làm.
protocol TodoListPresenterInput: AnyObject {
    /// View đã load xong
    func viewDidLoad()
    /// View sắp xuất hiện (refresh data từ repo — cần cho sync sau Detail)
    func viewWillAppear()

    /// User muốn thêm todo mới
    func didTapAddTodo(title: String)
    /// User muốn xoá todo tại index
    func didTapDeleteTodo(at index: Int)
    /// User tap vào 1 todo item để xem chi tiết
    func didSelectTodo(at index: Int)
    /// User toggle trạng thái complete
    func didToggleComplete(at index: Int)
    /// User muốn sửa title của todo
    func didEditTodo(at index: Int, newTitle: String)

    /// User gõ search query
    func didSearch(query: String)
    /// User chọn filter tab
    func didSelectFilter(_ filter: FilterType)
}

// MARK: - Presenter → View

/// Những gì Presenter "ra lệnh" cho View thực hiện.
protocol TodoListPresenterOutput: AnyObject {
    func displayTodos(_ viewModels: [TodoViewModel])
    func displayError(_ message: String)
    func displayLoading(_ isLoading: Bool)
}

// MARK: - Presenter → Interactor

protocol TodoListInteractorInput: AnyObject {
    func fetchTodos()
    func addTodo(title: String)
    func deleteTodo(id: UUID)
    func toggleComplete(id: UUID)
    func editTodo(id: UUID, newTitle: String)
}

// MARK: - Interactor → Presenter

protocol TodoListInteractorOutput: AnyObject {
    func didFetchTodos(_ items: [TodoItem])
    func didAddTodo(_ item: TodoItem)
    func didDeleteTodo(id: UUID)
    func didToggleComplete(_ item: TodoItem)
    func didEditTodo(_ item: TodoItem)
    func didFailWithError(_ error: Error)
}

// MARK: - Router

protocol TodoListRouterInput: AnyObject {
    func navigateToDetail(with item: TodoItem)
    static func createModule() -> UIViewController
}
