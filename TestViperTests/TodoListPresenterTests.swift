//
//  TodoListPresenterTests.swift
//  TestViperTests
//
//  ╔══════════════════════════════════════════════════════════════╗
//  ║  UNIT TESTS: TodoListPresenter                               ║
//  ╚══════════════════════════════════════════════════════════════╝
//
//  Đây là nơi ta test PRESENTER — layer quan trọng nhất.
//
//  Setup cho mỗi test:
//    - Tạo MockView (fake View)
//    - Tạo MockInteractor (fake Interactor)
//    - Inject vào Presenter
//    - Gọi method của Presenter → kiểm tra Mock có được gọi đúng không
//
//  ✅ Không cần UIViewController thật
//  ✅ Không cần simulator
//  ✅ Chạy cực nhanh (< 1ms mỗi test)
//
//  Swift Testing dùng @Test macro thay vì func test...() của XCTest.
//  #expect(...) thay vì XCTAssertEqual(...)
//

import Testing
import Foundation
@testable import TestViper

// MARK: - TodoListPresenterTests

@Suite("TodoListPresenter Tests")
struct TodoListPresenterTests {

    // Helpers: tạo SUT (System Under Test) với dependencies
    private func makeSUT() -> (
        presenter: TodoListPresenter,
        mockView: MockTodoListView,
        mockInteractor: MockTodoListInteractor
    ) {
        let presenter = TodoListPresenter()
        let mockView = MockTodoListView()
        let mockInteractor = MockTodoListInteractor()

        // Inject dependencies
        presenter.view = mockView
        presenter.interactor = mockInteractor

        return (presenter, mockView, mockInteractor)
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - viewDidLoad Tests
    // ─────────────────────────────────────────────────────────────

    @Test("viewDidLoad phải gọi interactor.fetchTodos()")
    func viewDidLoadShouldFetchTodos() {
        // Arrange: chuẩn bị
        let (presenter, _, mockInteractor) = makeSUT()

        // Act: hành động cần test
        presenter.viewDidLoad()

        // Assert: kiểm tra kết quả
        // #expect là cú pháp của Swift Testing (thay cho XCTAssertEqual)
        #expect(mockInteractor.fetchTodosCallCount == 1)
    }

    @Test("viewDidLoad phải hiển thị loading")
    func viewDidLoadShouldShowLoading() {
        let (presenter, mockView, _) = makeSUT()

        presenter.viewDidLoad()

        // Loading phải được bật trước khi fetch
        #expect(mockView.displayLoadingCallCount == 1)
        #expect(mockView.lastLoadingState == true)
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - didTapAddTodo Tests
    // ─────────────────────────────────────────────────────────────

    @Test("didTapAddTodo với title hợp lệ phải gọi interactor.addTodo()")
    func addTodoWithValidTitleShouldCallInteractor() {
        let (presenter, _, mockInteractor) = makeSUT()

        presenter.didTapAddTodo(title: "Mua sữa")

        #expect(mockInteractor.addTodoCallCount == 1)
        #expect(mockInteractor.lastAddedTitle == "Mua sữa")
    }

    @Test("didTapAddTodo với title rỗng vẫn gọi interactor (validate trong Interactor)")
    func addTodoWithEmptyTitleShouldStillCallInteractor() {
        // Lưu ý: Presenter KHÔNG validate — delegate cho Interactor.
        // Đây là separation of concerns: business rule ở Interactor.
        let (presenter, _, mockInteractor) = makeSUT()

        presenter.didTapAddTodo(title: "")

        // Presenter vẫn gọi — Interactor sẽ handle validation
        #expect(mockInteractor.addTodoCallCount == 1)
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - didTapDeleteTodo Tests
    // ─────────────────────────────────────────────────────────────

    @Test("didTapDeleteTodo với index hợp lệ phải gọi interactor.deleteTodo()")
    func deleteTodoShouldCallInteractor() {
        let (presenter, _, mockInteractor) = makeSUT()

        // Giả lập: Presenter đã có data (như sau khi fetch thành công)
        let item = TodoItem(title: "Test item")
        presenter.didFetchTodos([item]) // inject state vào presenter

        presenter.didTapDeleteTodo(at: 0)

        #expect(mockInteractor.deleteTodoCallCount == 1)
        #expect(mockInteractor.lastDeletedId == item.id)
    }

    @Test("didTapDeleteTodo với index out of bounds không crash và không gọi interactor")
    func deleteTodoWithOutOfBoundsIndexShouldNotCrash() {
        let (presenter, _, mockInteractor) = makeSUT()

        // Không có item nào trong list — index 0 là out of bounds
        presenter.didTapDeleteTodo(at: 0)

        #expect(mockInteractor.deleteTodoCallCount == 0) // Không được gọi
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - didFetchTodos (InteractorOutput) Tests
    // ─────────────────────────────────────────────────────────────

    @Test("didFetchTodos phải gọi view.displayTodos() với đúng số items")
    func didFetchTodosShouldDisplayCorrectCount() {
        let (presenter, mockView, _) = makeSUT()

        let items = [
            TodoItem(title: "Item 1"),
            TodoItem(title: "Item 2"),
            TodoItem(title: "Item 3"),
        ]
        presenter.didFetchTodos(items)

        #expect(mockView.displayTodosCallCount == 1)
        #expect(mockView.lastDisplayedViewModels.count == 3)
    }

    @Test("didFetchTodos với danh sách rỗng phải hiển thị 0 items")
    func didFetchEmptyTodosShouldDisplayEmpty() {
        let (presenter, mockView, _) = makeSUT()

        presenter.didFetchTodos([])

        #expect(mockView.displayTodosCallCount == 1)
        #expect(mockView.lastDisplayedViewModels.isEmpty)
    }

    @Test("ViewModel title phải khớp với Entity title")
    func viewModelTitleShouldMatchEntityTitle() throws {
        let (presenter, mockView, _) = makeSUT()

        let item = TodoItem(title: "Học VIPER")
        presenter.didFetchTodos([item])

        let viewModel = try #require(mockView.lastDisplayedViewModels.first)
        #expect(viewModel.title == "Học VIPER")
    }

    @Test("ViewModel status text phải đúng theo isCompleted")
    func viewModelStatusTextShouldReflectCompletionState() {
        let (presenter, mockView, _) = makeSUT()

        let completedItem = TodoItem(title: "Done", isCompleted: true)
        let pendingItem = TodoItem(title: "Pending", isCompleted: false)

        presenter.didFetchTodos([completedItem, pendingItem])

        let vms = mockView.lastDisplayedViewModels
        #expect(vms[0].statusText == "✓ Hoàn thành")
        #expect(vms[1].statusText == "○ Chưa xong")
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Error Handling Tests
    // ─────────────────────────────────────────────────────────────

    @Test("didFailWithError phải gọi view.displayError()")
    func didFailWithErrorShouldDisplayError() {
        let (presenter, mockView, _) = makeSUT()

        presenter.didFailWithError(TodoError.emptyTitle)

        #expect(mockView.displayErrorCallCount == 1)
        #expect(mockView.lastErrorMessage != nil)
    }

    @Test("didFailWithError phải tắt loading")
    func didFailWithErrorShouldHideLoading() {
        let (presenter, mockView, _) = makeSUT()

        presenter.didFailWithError(TodoError.emptyTitle)

        // Loading phải được tắt khi có lỗi
        #expect(mockView.lastLoadingState == false)
    }
}
