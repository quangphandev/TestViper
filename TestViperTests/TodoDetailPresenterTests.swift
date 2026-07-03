//
//  TodoDetailPresenterTests.swift
//  TestViperTests
//
//  ╔══════════════════════════════════════════════════════════════╗
//  ║  UNIT TESTS: TodoDetailPresenter                             ║
//  ╚══════════════════════════════════════════════════════════════╝
//

import Testing
import Foundation
import UIKit
@testable import TestViper

@Suite("TodoDetailPresenter Tests")
struct TodoDetailPresenterTests {

    // MARK: - SUT Helper

    private func makeSUT(
        item: TodoItem = TodoItem(title: "Test Item")
    ) -> (
        presenter: TodoDetailPresenter,
        mockView: MockTodoDetailView,
        mockInteractor: MockTodoDetailInteractor
    ) {
        let presenter      = TodoDetailPresenter()
        let mockView       = MockTodoDetailView()
        let mockInteractor = MockTodoDetailInteractor()

        mockInteractor.stubbedItem = item
        mockInteractor.output      = presenter

        presenter.view       = mockView
        presenter.interactor = mockInteractor

        return (presenter, mockView, mockInteractor)
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - viewDidLoad
    // ─────────────────────────────────────────────────────────────

    @Test("viewDidLoad phải gọi interactor.fetchTodo()")
    func viewDidLoadShouldFetchTodo() {
        let (presenter, _, mockInteractor) = makeSUT()
        presenter.viewDidLoad()
        #expect(mockInteractor.fetchTodoCallCount == 1)
    }

    @Test("viewDidLoad phải gọi view.displayTodo()")
    func viewDidLoadShouldDisplayTodo() {
        let item = TodoItem(title: "Học VIPER")
        let (presenter, mockView, _) = makeSUT(item: item)
        presenter.viewDidLoad()
        #expect(mockView.displayTodoCallCount == 1)
        #expect(mockView.lastTitle == "Học VIPER")
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Display Format
    // ─────────────────────────────────────────────────────────────

    @Test("Item chưa hoàn thành → status phải chứa 'Đang thực hiện'")
    func pendingItem_displaysCorrectStatus() {
        let item = TodoItem(title: "Chưa xong", isCompleted: false)
        let (presenter, mockView, _) = makeSUT(item: item)
        presenter.viewDidLoad()
        #expect(mockView.lastStatus?.contains("Đang thực hiện") == true)
        #expect(mockView.lastIsCompleted == false)
    }

    @Test("Item đã hoàn thành → status phải chứa 'Đã hoàn thành'")
    func completedItem_displaysCorrectStatus() {
        let item = TodoItem(title: "Đã xong", isCompleted: true)
        let (presenter, mockView, _) = makeSUT(item: item)
        presenter.viewDidLoad()
        #expect(mockView.lastStatus?.contains("Đã hoàn thành") == true)
        #expect(mockView.lastIsCompleted == true)
    }

    @Test("displayTodo phải truyền đúng title")
    func displayTodo_titleMatchesItem() throws {
        let item = TodoItem(title: "Mua sữa tươi 🥛")
        let (presenter, mockView, _) = makeSUT(item: item)
        presenter.viewDidLoad()
        let title = try #require(mockView.lastTitle)
        #expect(title == "Mua sữa tươi 🥛")
    }

    @Test("displayTodo phải truyền date string không rỗng")
    func displayTodo_dateIsNotEmpty() throws {
        let (presenter, mockView, _) = makeSUT()
        presenter.viewDidLoad()
        let date = try #require(mockView.lastDate)
        #expect(!date.isEmpty)
    }

    @Test("displayTodo phải truyền đúng priority")
    func displayTodo_priorityMatchesItem() {
        let item = TodoItem(title: "High priority", priority: .high)
        let (presenter, mockView, _) = makeSUT(item: item)
        presenter.viewDidLoad()
        #expect(mockView.lastPriority == .high)
    }

    @Test("displayTodo phải truyền dueDate = nil khi không đặt hạn")
    func displayTodo_dueDateNilWhenNotSet() {
        let item = TodoItem(title: "No due date", dueDate: nil)
        let (presenter, mockView, _) = makeSUT(item: item)
        presenter.viewDidLoad()
        #expect(mockView.lastDueDate == nil)
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Toggle Complete
    // ─────────────────────────────────────────────────────────────

    @Test("didTapToggleComplete phải gọi interactor.toggleComplete()")
    func didTapToggleComplete_callsInteractor() {
        let (presenter, _, mockInteractor) = makeSUT()
        presenter.didTapToggleComplete()
        #expect(mockInteractor.toggleCompleteCallCount == 1)
    }

    @Test("Toggle từ false → view phải hiển thị isCompleted = true")
    func toggleFromPending_viewShowsCompleted() {
        let item = TodoItem(title: "Chưa xong", isCompleted: false)
        let (presenter, mockView, _) = makeSUT(item: item)
        presenter.viewDidLoad()
        #expect(mockView.lastIsCompleted == false)
        presenter.didTapToggleComplete()
        #expect(mockView.displayTodoCallCount == 2)
        #expect(mockView.lastIsCompleted == true)
    }

    @Test("Toggle từ true → view phải hiển thị isCompleted = false")
    func toggleFromCompleted_viewShowsPending() {
        let item = TodoItem(title: "Đã xong", isCompleted: true)
        let (presenter, mockView, _) = makeSUT(item: item)
        presenter.viewDidLoad()
        presenter.didTapToggleComplete()
        #expect(mockView.lastIsCompleted == false)
    }

    @Test("Toggle 2 lần → trở về trạng thái ban đầu")
    func toggleTwice_returnsToOriginalState() {
        let item = TodoItem(title: "Test toggle 2 lần", isCompleted: false)
        let (presenter, mockView, _) = makeSUT(item: item)
        presenter.viewDidLoad()
        presenter.didTapToggleComplete()
        #expect(mockView.lastIsCompleted == true)
        presenter.didTapToggleComplete()
        #expect(mockView.lastIsCompleted == false)
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Priority
    // ─────────────────────────────────────────────────────────────

    @Test("didChangePriority phải gọi interactor.updatePriority()")
    func didChangePriority_callsInteractor() {
        let (presenter, _, mockInteractor) = makeSUT()
        presenter.didChangePriority(.high)
        #expect(mockInteractor.updatePriorityCallCount == 1)
        #expect(mockInteractor.lastPriority == .high)
    }

    @Test("didChangePriority phải update view với priority mới")
    func didChangePriority_updatesView() {
        let item = TodoItem(title: "Test", priority: .low)
        let (presenter, mockView, _) = makeSUT(item: item)
        presenter.viewDidLoad()
        presenter.didChangePriority(.high)
        #expect(mockView.lastPriority == .high)
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Due Date
    // ─────────────────────────────────────────────────────────────

    @Test("didSetDueDate phải gọi interactor.updateDueDate()")
    func didSetDueDate_callsInteractor() {
        let (presenter, _, mockInteractor) = makeSUT()
        let futureDate = Date().addingTimeInterval(86400)
        presenter.didSetDueDate(futureDate)
        #expect(mockInteractor.updateDueDateCallCount == 1)
    }

    @Test("didSetDueDate với nil phải gọi interactor.updateDueDate(nil)")
    func didSetDueDate_nil_callsInteractorWithNil() {
        let (presenter, _, mockInteractor) = makeSUT()
        presenter.didSetDueDate(nil)
        #expect(mockInteractor.updateDueDateCallCount == 1)
        // lastDueDate là Date?? — outer optional = was set, inner = nil value
        if case .some(let innerDate) = mockInteractor.lastDueDate {
            #expect(innerDate == nil)
        }
    }
}
