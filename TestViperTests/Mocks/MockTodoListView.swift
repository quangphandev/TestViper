//
//  MockTodoListView.swift
//  TestViperTests
//
//  ╔══════════════════════════════════════════════════════╗
//  ║  TESTING: Mock View                                  ║
//  ╚══════════════════════════════════════════════════════╝
//
//  Mock là một "giả lập" của dependency thật.
//  MockView giả lập TodoListViewController.
//
//  Cách hoạt động:
//    1. Presenter gọi view.displayTodos(viewModels)
//    2. MockView lưu lại: displayTodosCallCount += 1, lastViewModels = viewModels
//    3. Test kiểm tra: #expect(mockView.displayTodosCallCount == 1)
//
//  → Không cần UIKit, không cần simulator, test chạy cực nhanh!
//

import UIKit
@testable import TestViper

// MARK: - MockTodoListView

final class MockTodoListView: TodoListPresenterOutput {

    // Đếm số lần mỗi method được gọi
    private(set) var displayTodosCallCount = 0
    private(set) var displayErrorCallCount = 0
    private(set) var displayLoadingCallCount = 0

    // Lưu arguments của lần gọi cuối
    private(set) var lastDisplayedViewModels: [TodoViewModel] = []
    private(set) var lastErrorMessage: String?
    private(set) var lastLoadingState: Bool?

    // MARK: - TodoListPresenterOutput

    func displayTodos(_ viewModels: [TodoViewModel]) {
        displayTodosCallCount += 1
        lastDisplayedViewModels = viewModels
    }

    func displayError(_ message: String) {
        displayErrorCallCount += 1
        lastErrorMessage = message
    }

    func displayLoading(_ isLoading: Bool) {
        displayLoadingCallCount += 1
        lastLoadingState = isLoading
    }

    // MARK: - Reset (tiện cho test isolation)

    func reset() {
        displayTodosCallCount = 0
        displayErrorCallCount = 0
        displayLoadingCallCount = 0
        lastDisplayedViewModels = []
        lastErrorMessage = nil
        lastLoadingState = nil
    }
}
