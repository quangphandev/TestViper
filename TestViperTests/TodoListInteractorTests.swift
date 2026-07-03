//
//  TodoListInteractorTests.swift
//  TestViperTests
//
//  ╔══════════════════════════════════════════════════════════════╗
//  ║  UNIT TESTS: TodoListInteractor                              ║
//  ╚══════════════════════════════════════════════════════════════╝
//
//  Test Interactor = test business logic.
//  Setup cho mỗi test:
//    - Tạo MockRepository (fake data source)
//    - Tạo MockPresenter (fake output receiver)
//    - Inject vào Interactor
//    - Gọi method của Interactor → kiểm tra kết quả
//

import Testing
import Foundation
@testable import TestViper

// MARK: - MockPresenter (output của Interactor)

/// Mock để bắt kết quả Interactor trả về
final class MockTodoListInteractorOutput: TodoListInteractorOutput {
    private(set) var didFetchCount = 0
    private(set) var didAddCount = 0
    private(set) var didDeleteCount = 0
    private(set) var didToggleCount = 0
    private(set) var didEditCount = 0
    private(set) var didFailCount = 0

    private(set) var fetchedItems: [TodoItem] = []
    private(set) var addedItem: TodoItem?
    private(set) var deletedId: UUID?
    private(set) var toggledItem: TodoItem?
    private(set) var editedItem: TodoItem?
    private(set) var lastError: Error?

    func didFetchTodos(_ items: [TodoItem]) { didFetchCount += 1; fetchedItems = items }
    func didAddTodo(_ item: TodoItem) { didAddCount += 1; addedItem = item }
    func didDeleteTodo(id: UUID) { didDeleteCount += 1; deletedId = id }
    func didToggleComplete(_ item: TodoItem) { didToggleCount += 1; toggledItem = item }
    func didEditTodo(_ item: TodoItem) { didEditCount += 1; editedItem = item }
    func didFailWithError(_ error: Error) { didFailCount += 1; lastError = error }
}

// MARK: - TodoListInteractorTests

@Suite("TodoListInteractor Tests")
struct TodoListInteractorTests {

    private func makeSUT(stubbedItems: [TodoItem] = []) -> (
        interactor: TodoListInteractor,
        mockRepo: MockTodoRepository,
        mockOutput: MockTodoListInteractorOutput
    ) {
        let mockRepo = MockTodoRepository()
        mockRepo.stubbedItems = stubbedItems

        let interactor = TodoListInteractor(repository: mockRepo)
        let mockOutput = MockTodoListInteractorOutput()
        interactor.output = mockOutput

        return (interactor, mockRepo, mockOutput)
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - fetchTodos Tests
    // ─────────────────────────────────────────────────────────────

    @Test("fetchTodos phải gọi repository.fetchAll()")
    func fetchTodosShouldCallRepository() {
        let (interactor, mockRepo, _) = makeSUT()

        interactor.fetchTodos()

        #expect(mockRepo.fetchAllCallCount == 1)
    }

    @Test("fetchTodos phải báo output đúng số items")
    func fetchTodosShouldNotifyOutputWithItems() {
        let items = [TodoItem(title: "A"), TodoItem(title: "B")]
        let (interactor, _, mockOutput) = makeSUT(stubbedItems: items)

        interactor.fetchTodos()

        #expect(mockOutput.didFetchCount == 1)
        #expect(mockOutput.fetchedItems.count == 2)
    }

    @Test("fetchTodos với repo rỗng phải trả về array rỗng")
    func fetchTodosWithEmptyRepoShouldReturnEmpty() {
        let (interactor, _, mockOutput) = makeSUT()

        interactor.fetchTodos()

        #expect(mockOutput.fetchedItems.isEmpty)
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - addTodo Tests
    // ─────────────────────────────────────────────────────────────

    @Test("addTodo với title hợp lệ phải lưu vào repository")
    func addTodoWithValidTitleShouldSaveToRepo() {
        let (interactor, mockRepo, _) = makeSUT()

        interactor.addTodo(title: "Mua rau")

        #expect(mockRepo.saveCallCount == 1)
        #expect(mockRepo.lastSavedItem?.title == "Mua rau")
    }

    @Test("addTodo với title hợp lệ phải notify output.didAddTodo()")
    func addTodoWithValidTitleShouldNotifyOutput() {
        let (interactor, _, mockOutput) = makeSUT()

        interactor.addTodo(title: "Tập gym")

        #expect(mockOutput.didAddCount == 1)
        #expect(mockOutput.addedItem?.title == "Tập gym")
    }

    @Test("addTodo với title rỗng phải báo lỗi")
    func addTodoWithEmptyTitleShouldFail() {
        let (interactor, mockRepo, mockOutput) = makeSUT()

        interactor.addTodo(title: "")

        // Không lưu vào repo
        #expect(mockRepo.saveCallCount == 0)
        // Phải báo lỗi
        #expect(mockOutput.didFailCount == 1)
    }

    @Test("addTodo với title chỉ có whitespace phải báo lỗi")
    func addTodoWithWhitespaceTitleShouldFail() {
        let (interactor, mockRepo, mockOutput) = makeSUT()

        interactor.addTodo(title: "   \n\t  ")

        #expect(mockRepo.saveCallCount == 0)
        #expect(mockOutput.didFailCount == 1)
    }

    @Test("addTodo phải trim whitespace và lưu title sạch")
    func addTodoShouldTrimWhitespace() {
        let (interactor, mockRepo, _) = makeSUT()

        interactor.addTodo(title: "  Học VIPER  ")

        #expect(mockRepo.lastSavedItem?.title == "Học VIPER")
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - deleteTodo Tests
    // ─────────────────────────────────────────────────────────────

    @Test("deleteTodo phải gọi repository.delete(id:)")
    func deleteTodoShouldCallRepository() {
        let item = TodoItem(title: "Cần xoá")
        let (interactor, mockRepo, _) = makeSUT(stubbedItems: [item])

        interactor.deleteTodo(id: item.id)

        #expect(mockRepo.deleteCallCount == 1)
        #expect(mockRepo.lastDeletedId == item.id)
    }

    @Test("deleteTodo phải notify output.didDeleteTodo(id:)")
    func deleteTodoShouldNotifyOutput() {
        let item = TodoItem(title: "Cần xoá")
        let (interactor, _, mockOutput) = makeSUT(stubbedItems: [item])

        interactor.deleteTodo(id: item.id)

        #expect(mockOutput.didDeleteCount == 1)
        #expect(mockOutput.deletedId == item.id)
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - toggleComplete Tests
    // ─────────────────────────────────────────────────────────────

    @Test("toggleComplete phải đổi isCompleted từ false sang true")
    func toggleCompleteShouldFlipFalseToTrue() {
        let item = TodoItem(title: "Chưa xong", isCompleted: false)
        let (interactor, _, mockOutput) = makeSUT(stubbedItems: [item])

        interactor.toggleComplete(id: item.id)

        #expect(mockOutput.toggledItem?.isCompleted == true)
    }

    @Test("toggleComplete phải đổi isCompleted từ true sang false")
    func toggleCompleteShouldFlipTrueToFalse() {
        let item = TodoItem(title: "Đã xong", isCompleted: true)
        let (interactor, _, mockOutput) = makeSUT(stubbedItems: [item])

        interactor.toggleComplete(id: item.id)

        #expect(mockOutput.toggledItem?.isCompleted == false)
    }

    @Test("toggleComplete phải gọi repository.update()")
    func toggleCompleteShouldUpdateRepo() {
        let item = TodoItem(title: "Test", isCompleted: false)
        let (interactor, mockRepo, _) = makeSUT(stubbedItems: [item])

        interactor.toggleComplete(id: item.id)

        #expect(mockRepo.updateCallCount == 1)
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - editTodo Tests
    // ─────────────────────────────────────────────────────────────

    @Test("editTodo với title hợp lệ phải update repository")
    func editTodoWithValidTitleShouldUpdateRepo() {
        let item = TodoItem(title: "Học Swift")
        let (interactor, mockRepo, _) = makeSUT(stubbedItems: [item])

        interactor.editTodo(id: item.id, newTitle: "Học Swift nâng cao")

        #expect(mockRepo.updateCallCount == 1)
        #expect(mockRepo.lastUpdatedItem?.title == "Học Swift nâng cao")
    }

    @Test("editTodo với title hợp lệ phải notify output")
    func editTodoWithValidTitleShouldNotifyOutput() {
        let item = TodoItem(title: "Học Swift")
        let (interactor, _, mockOutput) = makeSUT(stubbedItems: [item])

        interactor.editTodo(id: item.id, newTitle: "Học Swift nâng cao")

        #expect(mockOutput.didEditCount == 1)
        #expect(mockOutput.editedItem?.title == "Học Swift nâng cao")
    }

    @Test("editTodo với title rỗng phải báo lỗi và không update")
    func editTodoWithEmptyTitleShouldFail() {
        let item = TodoItem(title: "Học Swift")
        let (interactor, mockRepo, mockOutput) = makeSUT(stubbedItems: [item])

        interactor.editTodo(id: item.id, newTitle: "")

        #expect(mockRepo.updateCallCount == 0)
        #expect(mockOutput.didFailCount == 1)
    }
}
