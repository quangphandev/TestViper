//
//  TodoListProtocols.swift
//  TestViper
//
//  ╔══════════════════════════════════════════════════════════╗
//  ║  VIPER: PROTOCOL DEFINITIONS cho module TodoList         ║
//  ╚══════════════════════════════════════════════════════════╝
//
//  Đây là file QUAN TRỌNG NHẤT trong một VIPER module.
//  Tất cả "hợp đồng" (contract) giao tiếp giữa các layer được
//  định nghĩa tại đây.
//
//  Sơ đồ giao tiếp:
//
//  ┌──────────┐  PresenterInput  ┌───────────┐
//  │          │ ──────────────► │           │
//  │   View   │                  │ Presenter │
//  │          │ ◄────────────── │           │
//  └──────────┘  PresenterOutput └─────┬─────┘
//                                      │ InteractorInput
//                                      ▼
//                               ┌───────────┐
//                               │ Interactor│
//                               └─────┬─────┘
//                                     │ InteractorOutput
//                                     ▼
//                               (quay về Presenter)
//
//  Quy ước đặt tên protocol:
//    - [Module]PresenterInput:  View → Presenter
//    - [Module]PresenterOutput: Presenter → View (display commands)
//    - [Module]InteractorInput: Presenter → Interactor
//    - [Module]InteractorOutput: Interactor → Presenter
//    - [Module]RouterInput:     Presenter → Router
//

import UIKit

// MARK: - ViewModel

/// ViewModel là data đã được FORMAT sẵn để View hiển thị.
/// Presenter tạo ra ViewModel từ Entity (TodoItem).
///
/// Tại sao không truyền thẳng Entity cho View?
/// → View không cần biết business model (Entity).
/// → View chỉ cần string/bool để display — ViewModel cung cấp đúng thứ đó.
struct TodoViewModel {
    let id: UUID
    let title: String

    // Presenter đã format sẵn: "✓ Hoàn thành" hoặc "○ Chưa xong"
    let statusText: String
    let statusColor: UIColor

    // Presenter đã format date: "02/07/2026 15:00"
    let dateText: String
}

// MARK: - View → Presenter

/// Những gì View có thể "yêu cầu" Presenter làm.
/// View KHÔNG tự làm logic — nó chỉ delegate cho Presenter.
protocol TodoListPresenterInput: AnyObject {
    /// View đã load xong — lấy data để hiển thị
    func viewDidLoad()

    /// User muốn thêm todo mới
    func didTapAddTodo(title: String)

    /// User muốn xoá todo tại vị trí index
    func didTapDeleteTodo(at index: Int)

    /// User tap vào 1 todo item để xem chi tiết
    func didSelectTodo(at index: Int)

    /// User toggle trạng thái complete của todo
    func didToggleComplete(at index: Int)
}

// MARK: - Presenter → View

/// Những gì Presenter "ra lệnh" cho View thực hiện.
/// Đây đều là các lệnh hiển thị thuần — không có logic.
protocol TodoListPresenterOutput: AnyObject {
    /// Hiển thị danh sách todos (đã format xong)
    func displayTodos(_ viewModels: [TodoViewModel])

    /// Hiển thị thông báo lỗi
    func displayError(_ message: String)

    /// Hiển thị trạng thái loading
    func displayLoading(_ isLoading: Bool)
}

// MARK: - Presenter → Interactor

/// Những gì Presenter "yêu cầu" Interactor làm (business logic).
protocol TodoListInteractorInput: AnyObject {
    func fetchTodos()
    func addTodo(title: String)
    func deleteTodo(id: UUID)
    func toggleComplete(id: UUID)
}

// MARK: - Interactor → Presenter

/// Interactor trả kết quả về cho Presenter qua protocol này.
/// Lưu ý: Interactor KHÔNG biết Presenter là ai — nó chỉ gọi qua protocol.
protocol TodoListInteractorOutput: AnyObject {
    func didFetchTodos(_ items: [TodoItem])
    func didAddTodo(_ item: TodoItem)
    func didDeleteTodo(id: UUID)
    func didToggleComplete(_ item: TodoItem)
    func didFailWithError(_ error: Error)
}

// MARK: - Router

/// Những gì Presenter "yêu cầu" Router làm (navigation).
protocol TodoListRouterInput: AnyObject {
    /// Navigate sang màn hình Detail với item cụ thể
    func navigateToDetail(with item: TodoItem)

    /// Factory method — tạo và wire-up toàn bộ VIPER module
    static func createModule() -> UIViewController
}
