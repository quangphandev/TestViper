//
//  MockTodoRepository.swift
//  TestViperTests
//
//  ╔══════════════════════════════════════════════════════╗
//  ║  TESTING: Mock Repository                            ║
//  ╚══════════════════════════════════════════════════════╝
//
//  Mock Repository dùng khi test Interactor.
//  Ta muốn kiểm tra business logic của Interactor mà không
//  cần biết data thật đến từ đâu.
//
//  MockTodoRepository cho phép:
//  1. Seed data trước khi test: mockRepo.stubbedItems = [item1, item2]
//  2. Kiểm tra repo có được gọi đúng: #expect(mockRepo.saveCallCount == 1)
//

import Foundation
@testable import TestViper

// MARK: - MockTodoRepository

final class MockTodoRepository: TodoRepositoryProtocol {

    // "Stub" — dữ liệu giả để inject
    var stubbedItems: [TodoItem] = []

    // Ghi lại những gì được gọi
    private(set) var fetchAllCallCount = 0
    private(set) var saveCallCount = 0
    private(set) var deleteCallCount = 0
    private(set) var updateCallCount = 0

    private(set) var lastSavedItem: TodoItem?
    private(set) var lastDeletedId: UUID?
    private(set) var lastUpdatedItem: TodoItem?

    // MARK: - TodoRepositoryProtocol

    func fetchAll() -> [TodoItem] {
        fetchAllCallCount += 1
        return stubbedItems
    }

    func save(_ item: TodoItem) {
        saveCallCount += 1
        lastSavedItem = item
        // Thêm vào stubbed items để simulate lưu thật
        stubbedItems.append(item)
    }

    func delete(id: UUID) {
        deleteCallCount += 1
        lastDeletedId = id
        stubbedItems.removeAll { $0.id == id }
    }

    func update(_ item: TodoItem) {
        updateCallCount += 1
        lastUpdatedItem = item
        if let idx = stubbedItems.firstIndex(where: { $0.id == item.id }) {
            stubbedItems[idx] = item
        }
    }
}
