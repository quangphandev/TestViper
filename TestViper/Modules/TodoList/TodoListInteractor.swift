//
//  TodoListInteractor.swift
//  TestViper
//
//  ╔══════════════════════════════════════════╗
//  ║  VIPER Layer: INTERACTOR                 ║
//  ╚══════════════════════════════════════════╝
//

import Foundation

// MARK: - TodoListInteractor

final class TodoListInteractor {

    weak var output: TodoListInteractorOutput?
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol = InMemoryTodoRepository()) {
        self.repository = repository
    }
}

// MARK: - TodoListInteractorInput

extension TodoListInteractor: TodoListInteractorInput {

    func fetchTodos() {
        let items = repository.fetchAll()
        output?.didFetchTodos(items)
    }

    func addTodo(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            output?.didFailWithError(TodoError.emptyTitle)
            return
        }
        let newItem = TodoItem(title: trimmed)
        repository.save(newItem)
        output?.didAddTodo(newItem)
    }

    func deleteTodo(id: UUID) {
        repository.delete(id: id)
        output?.didDeleteTodo(id: id)
    }

    func toggleComplete(id: UUID) {
        var items = repository.fetchAll()
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].isCompleted.toggle()
        repository.update(items[index])
        output?.didToggleComplete(items[index])
    }

    func editTodo(id: UUID, newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            output?.didFailWithError(TodoError.emptyTitle)
            return
        }
        var items = repository.fetchAll()
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            output?.didFailWithError(TodoError.itemNotFound)
            return
        }
        items[index].title = trimmed
        repository.update(items[index])
        output?.didEditTodo(items[index])
    }
}

// MARK: - TodoError

enum TodoError: LocalizedError {
    case emptyTitle
    case itemNotFound

    var errorDescription: String? {
        switch self {
        case .emptyTitle:   return "Tiêu đề todo không được để trống."
        case .itemNotFound: return "Không tìm thấy todo item."
        }
    }
}
