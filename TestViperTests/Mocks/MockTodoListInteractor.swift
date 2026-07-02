//
//  MockTodoListInteractor.swift
//  TestViperTests
//
//  ╔══════════════════════════════════════════════════════╗
//  ║  TESTING: Mock Interactor                            ║
//  ╚══════════════════════════════════════════════════════╝
//
//  Mock Interactor dùng khi test Presenter.
//  Ta muốn kiểm tra: "Khi viewDidLoad(), Presenter có gọi fetchTodos() không?"
//  → Không cần Interactor thật — chỉ cần Mock ghi lại việc được gọi.
//

import Foundation
@testable import TestViper

// MARK: - MockTodoListInteractor

final class MockTodoListInteractor: TodoListInteractorInput {

    // Ghi lại những gì Presenter đã yêu cầu
    private(set) var fetchTodosCallCount = 0
    private(set) var addTodoCallCount = 0
    private(set) var deleteTodoCallCount = 0
    private(set) var toggleCompleteCallCount = 0

    private(set) var lastAddedTitle: String?
    private(set) var lastDeletedId: UUID?
    private(set) var lastToggledId: UUID?

    // MARK: - TodoListInteractorInput

    func fetchTodos() {
        fetchTodosCallCount += 1
    }

    func addTodo(title: String) {
        addTodoCallCount += 1
        lastAddedTitle = title
    }

    func deleteTodo(id: UUID) {
        deleteTodoCallCount += 1
        lastDeletedId = id
    }

    func toggleComplete(id: UUID) {
        toggleCompleteCallCount += 1
        lastToggledId = id
    }
}
