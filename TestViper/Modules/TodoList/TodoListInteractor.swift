//
//  TodoListInteractor.swift
//  TestViper
//
//  ╔══════════════════════════════════════════╗
//  ║  VIPER Layer: INTERACTOR                 ║
//  ╚══════════════════════════════════════════╝
//
//  Interactor là nơi chứa BUSINESS LOGIC.
//  Định nghĩa:
//    ✅ Gọi Repository để lấy/lưu data
//    ✅ Áp dụng các business rules (validate, filter, sort...)
//    ✅ KHÔNG biết UIKit — không import UIKit
//    ✅ KHÔNG format data cho UI (Presenter làm việc đó)
//    ✅ Trả kết quả về Presenter qua InteractorOutput protocol
//
//  Test Interactor bằng cách inject MockRepository.
//

import Foundation

// MARK: - TodoListInteractor

final class TodoListInteractor {

    // ⚠️ Weak reference để tránh retain cycle:
    // Interactor → (strong) Presenter → (strong) Interactor → 💥 retain cycle
    // Vì vậy phải dùng weak var cho output
    weak var output: TodoListInteractorOutput?

    // Dependency Injection qua init — dễ swap và test
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol = InMemoryTodoRepository()) {
        self.repository = repository
    }
}

// MARK: - TodoListInteractorInput

extension TodoListInteractor: TodoListInteractorInput {

    func fetchTodos() {
        // Lấy tất cả từ repository và báo Presenter
        let items = repository.fetchAll()
        output?.didFetchTodos(items)
    }

    func addTodo(title: String) {
        // Business rule: title không được rỗng sau khi trim whitespace
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            output?.didFailWithError(TodoError.emptyTitle)
            return
        }

        // Tạo Entity mới và lưu vào repository
        let newItem = TodoItem(title: trimmed)
        repository.save(newItem)

        // Báo Presenter biết item nào vừa được thêm
        output?.didAddTodo(newItem)
    }

    func deleteTodo(id: UUID) {
        repository.delete(id: id)
        output?.didDeleteTodo(id: id)
    }

    func toggleComplete(id: UUID) {
        // Lấy tất cả items từ repo, tìm item cần toggle
        var items = repository.fetchAll()
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        // Toggle isCompleted
        items[index].isCompleted.toggle()
        repository.update(items[index])

        output?.didToggleComplete(items[index])
    }
}

// MARK: - TodoError

/// Business errors — định nghĩa trong Interactor vì đây là business logic
enum TodoError: LocalizedError {
    case emptyTitle
    case itemNotFound

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Tiêu đề todo không được để trống."
        case .itemNotFound:
            return "Không tìm thấy todo item."
        }
    }
}
