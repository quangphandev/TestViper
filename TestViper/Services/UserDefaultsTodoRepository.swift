//
//  UserDefaultsTodoRepository.swift
//  TestViper
//
//  ╔══════════════════════════════════════════╗
//  ║  Layer: SERVICE / DATA LAYER             ║
//  ╚══════════════════════════════════════════╝
//
//  Persistence bằng UserDefaults + JSON.
//  TodoItem conform Codable → JSONEncoder/Decoder tự xử lý.
//
//  Dùng thay InMemoryTodoRepository trong production để data
//  không mất khi app tắt.
//
//  Key "todo.items.v1" — đổi version nếu schema thay đổi
//  không tương thích để tránh decode error.
//

import Foundation

// MARK: - UserDefaultsTodoRepository

final class UserDefaultsTodoRepository: TodoRepositoryProtocol {

    private let storageKey = "todo.items.v1"
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Private Storage

    private var items: [TodoItem] {
        get {
            guard let data = defaults.data(forKey: storageKey) else { return [] }
            return (try? decoder.decode([TodoItem].self, from: data)) ?? []
        }
        set {
            guard let data = try? encoder.encode(newValue) else { return }
            defaults.set(data, forKey: storageKey)
        }
    }

    // MARK: - TodoRepositoryProtocol

    func fetchAll() -> [TodoItem] {
        items
    }

    func save(_ item: TodoItem) {
        var current = items
        current.append(item)
        items = current
    }

    func delete(id: UUID) {
        items = items.filter { $0.id != id }
    }

    func update(_ item: TodoItem) {
        var current = items
        guard let index = current.firstIndex(where: { $0.id == item.id }) else { return }
        current[index] = item
        items = current
    }
}
