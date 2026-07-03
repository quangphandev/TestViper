//
//  MockTodoDetailInteractor.swift
//  TestViperTests
//

import Foundation
@testable import TestViper

final class MockTodoDetailInteractor: TodoDetailInteractorInput {

    private(set) var fetchTodoCallCount = 0
    private(set) var toggleCompleteCallCount = 0
    private(set) var updatePriorityCallCount = 0
    private(set) var updateDueDateCallCount = 0

    private(set) var lastPriority: Priority?
    private(set) var lastDueDate: Date??  // Double optional: outer = was set, inner = value

    var stubbedItem: TodoItem?
    weak var output: TodoDetailInteractorOutput?

    func fetchTodo() {
        fetchTodoCallCount += 1
        if let item = stubbedItem { output?.didFetchTodo(item) }
    }

    func toggleComplete() {
        toggleCompleteCallCount += 1
        if var item = stubbedItem {
            item.isCompleted.toggle()
            stubbedItem = item
            output?.didUpdateTodo(item)
        }
    }

    func updatePriority(_ priority: Priority) {
        updatePriorityCallCount += 1
        lastPriority = priority
        if var item = stubbedItem {
            item.priority = priority
            stubbedItem = item
            output?.didUpdateTodo(item)
        }
    }

    func updateDueDate(_ date: Date?) {
        updateDueDateCallCount += 1
        lastDueDate = date
        if var item = stubbedItem {
            item.dueDate = date
            stubbedItem = item
            output?.didUpdateTodo(item)
        }
    }
}
