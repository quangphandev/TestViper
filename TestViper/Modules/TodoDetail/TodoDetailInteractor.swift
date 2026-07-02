//
//  TodoDetailInteractor.swift
//  TestViper
//
//  Interactor của TodoDetail đơn giản:
//  Chỉ trả lại item đã được truyền vào khi khởi tạo.
//  Trong app thực: có thể fetch lại từ API để refresh data.
//

import Foundation

final class TodoDetailInteractor {
    weak var output: TodoDetailInteractorOutput?

    // Item được inject khi Router tạo module
    private let item: TodoItem

    init(item: TodoItem) {
        self.item = item
    }
}

extension TodoDetailInteractor: TodoDetailInteractorInput {
    func fetchTodo() {
        output?.didFetchTodo(item)
    }
}
