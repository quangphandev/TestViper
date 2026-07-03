//
//  TodoDetailInteractor.swift
//  TestViper
//
//  ✅ Bug Fix: Interactor nhận shared repository từ Router.
//  Khi toggle/update, persist vào repository → List sẽ fetch lại khi appear.
//

import Foundation

final class TodoDetailInteractor {
    weak var output: TodoDetailInteractorOutput?

    private var item: TodoItem
    private let repository: TodoRepositoryProtocol

    init(item: TodoItem, repository: TodoRepositoryProtocol) {
        self.item = item
        self.repository = repository
    }
}

extension TodoDetailInteractor: TodoDetailInteractorInput {

    func fetchTodo() {
        output?.didFetchTodo(item)
    }

    func toggleComplete() {
        item.isCompleted.toggle()
        repository.update(item)           // ✅ Persist vào shared repo
        output?.didUpdateTodo(item)
    }

    func updatePriority(_ priority: Priority) {
        item.priority = priority
        repository.update(item)
        output?.didUpdateTodo(item)
    }

    func updateDueDate(_ date: Date?) {
        item.dueDate = date
        repository.update(item)
        output?.didUpdateTodo(item)
    }
}
