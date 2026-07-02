//
//  TodoRepository.swift
//  TestViper
//
//  ╔══════════════════════════════════════════╗
//  ║  Layer: SERVICE / DATA LAYER             ║
//  ╚══════════════════════════════════════════╝
//
//  Repository Pattern:
//  Interactor KHÔNG biết data đến từ đâu (API, CoreData, UserDefaults…).
//  Nó chỉ gọi qua protocol. Điều này giúp:
//    ✅ Swap data source dễ dàng (từ in-memory → CoreData → API)
//    ✅ Inject MockRepository trong unit test
//
//  Đây là pattern "Dependency Inversion" (chữ D trong SOLID).
//

import Foundation

// MARK: - Protocol (Interface)

/// Giao diện mà Interactor nhìn thấy.
/// Interactor chỉ biết protocol này, không biết implementation.
protocol TodoRepositoryProtocol: AnyObject {
    func fetchAll() -> [TodoItem]
    func save(_ item: TodoItem)
    func delete(id: UUID)
    func update(_ item: TodoItem)
}

// MARK: - InMemoryTodoRepository (Concrete Implementation)

/// Lưu data trong RAM — mất khi app tắt.
/// Phù hợp cho mục đích học tập và unit test.
/// Trong production: thay bằng CoreDataTodoRepository hoặc APITodoRepository.
final class InMemoryTodoRepository: TodoRepositoryProtocol {

    // Private mutable array — chỉ repository biết về storage này
    private var items: [TodoItem] = []

    func fetchAll() -> [TodoItem] {
        return items
    }

    func save(_ item: TodoItem) {
        items.append(item)
    }

    func delete(id: UUID) {
        // removeAll với closure: xoá tất cả phần tử có id trùng
        items.removeAll { $0.id == id }
    }

    func update(_ item: TodoItem) {
        // Tìm index bằng id, sau đó replace toàn bộ struct
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index] = item
    }
}
