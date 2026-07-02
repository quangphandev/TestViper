//
//  TodoListPresenter.swift
//  TestViper
//
//  ╔══════════════════════════════════════════╗
//  ║  VIPER Layer: PRESENTER                  ║
//  ╚══════════════════════════════════════════╝
//
//  Presenter là "bộ não" của module — đây là layer được test NHIỀU NHẤT.
//
//  Presenter làm gì?
//    ✅ Nhận user action từ View → gọi Interactor
//    ✅ Nhận raw data từ Interactor → FORMAT thành ViewModel → cập nhật View
//    ✅ Quyết định khi nào navigate → gọi Router
//    ✅ KHÔNG import UIKit (không có UIColor, UIFont... trực tiếp ở đây)
//       → Ngoại lệ: UIColor được define trong ViewModel ở Protocols file
//    ✅ KHÔNG có UIKit logic — không gọi tableView.reloadData()
//
//  Vì Presenter KHÔNG có UIKit → test nhanh, không cần simulator.
//

import UIKit // Chỉ dùng cho UIColor trong ViewModel

// MARK: - TodoListPresenter

final class TodoListPresenter {

    // ⚠️ weak var để tránh retain cycle: Presenter ↔ View
    // View giữ strong reference đến Presenter (owner)
    // Presenter chỉ giữ weak reference về View
    weak var view: TodoListPresenterOutput?

    // Presenter giữ strong reference đến các dependency này
    var interactor: TodoListInteractorInput?
    var router: TodoListRouterInput?

    // Cache danh sách items hiện tại — dùng để map index → id khi user xoá/toggle
    private var currentItems: [TodoItem] = []

    // MARK: - Private Helpers

    /// Format TodoItem → TodoViewModel
    /// Đây là "presentation logic" — không phải business logic.
    private func makeViewModel(from item: TodoItem) -> TodoViewModel {
        // Format date
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        let dateText = formatter.string(from: item.createdAt)

        // Format status
        let statusText = item.isCompleted ? "✓ Hoàn thành" : "○ Chưa xong"
        let statusColor: UIColor = item.isCompleted ? .systemGreen : .systemOrange

        return TodoViewModel(
            id: item.id,
            title: item.title,
            statusText: statusText,
            statusColor: statusColor,
            dateText: dateText
        )
    }
}

// MARK: - TodoListPresenterInput (nhận action từ View)

extension TodoListPresenter: TodoListPresenterInput {

    func viewDidLoad() {
        // View đã sẵn sàng → yêu cầu Interactor fetch data
        view?.displayLoading(true)
        interactor?.fetchTodos()
    }

    func didTapAddTodo(title: String) {
        // Không validate ở đây — delegate toàn bộ cho Interactor
        // Interactor có business rule → dễ test riêng lẻ
        interactor?.addTodo(title: title)
    }

    func didTapDeleteTodo(at index: Int) {
        guard index < currentItems.count else { return }
        let item = currentItems[index]
        interactor?.deleteTodo(id: item.id)
    }

    func didSelectTodo(at index: Int) {
        guard index < currentItems.count else { return }
        let item = currentItems[index]
        // Yêu cầu Router navigate — Presenter không tự navigate
        router?.navigateToDetail(with: item)
    }

    func didToggleComplete(at index: Int) {
        guard index < currentItems.count else { return }
        let item = currentItems[index]
        interactor?.toggleComplete(id: item.id)
    }
}

// MARK: - TodoListInteractorOutput (nhận kết quả từ Interactor)

extension TodoListPresenter: TodoListInteractorOutput {

    func didFetchTodos(_ items: [TodoItem]) {
        currentItems = items
        view?.displayLoading(false)
        // Format toàn bộ items → ViewModels rồi bảo View render
        let viewModels = items.map { makeViewModel(from: $0) }
        view?.displayTodos(viewModels)
    }

    func didAddTodo(_ item: TodoItem) {
        // Thêm vào cache local
        currentItems.append(item)
        // Re-render toàn bộ list (đơn giản hơn so với insert 1 row)
        let viewModels = currentItems.map { makeViewModel(from: $0) }
        view?.displayTodos(viewModels)
    }

    func didDeleteTodo(id: UUID) {
        // Xoá khỏi cache local
        currentItems.removeAll { $0.id == id }
        let viewModels = currentItems.map { makeViewModel(from: $0) }
        view?.displayTodos(viewModels)
    }

    func didToggleComplete(_ item: TodoItem) {
        // Cập nhật item trong cache
        if let index = currentItems.firstIndex(where: { $0.id == item.id }) {
            currentItems[index] = item
        }
        let viewModels = currentItems.map { makeViewModel(from: $0) }
        view?.displayTodos(viewModels)
    }

    func didFailWithError(_ error: Error) {
        view?.displayLoading(false)
        view?.displayError(error.localizedDescription)
    }
}
