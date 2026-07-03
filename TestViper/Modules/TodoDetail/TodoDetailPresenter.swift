//
//  TodoDetailPresenter.swift
//  TestViper
//

import UIKit

final class TodoDetailPresenter {
    weak var view: TodoDetailPresenterOutput?
    var interactor: TodoDetailInteractorInput?
    var router: TodoDetailRouterInput?
}

extension TodoDetailPresenter: TodoDetailPresenterInput {

    func viewDidLoad() {
        interactor?.fetchTodo()
    }

    func didTapToggleComplete() {
        interactor?.toggleComplete()
    }

    func didChangePriority(_ priority: Priority) {
        interactor?.updatePriority(priority)
    }

    func didSetDueDate(_ date: Date?) {
        interactor?.updateDueDate(date)
    }
}

extension TodoDetailPresenter: TodoDetailInteractorOutput {

    func didFetchTodo(_ item: TodoItem) {
        display(item: item)
    }

    func didUpdateTodo(_ item: TodoItem) {
        display(item: item)
    }

    // MARK: - Private Helpers

    private func display(item: TodoItem) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMMM yyyy 'lúc' HH:mm"
        formatter.locale = Locale(identifier: "vi_VN")
        let dateText = formatter.string(from: item.createdAt)

        let status = item.isCompleted ? "✅ Đã hoàn thành" : "🔵 Đang thực hiện"
        let statusColor: UIColor = item.isCompleted ? AppTheme.Color.success : AppTheme.Color.primary

        view?.displayTodo(
            title: item.title,
            status: status,
            statusColor: statusColor,
            date: dateText,
            isCompleted: item.isCompleted,
            priority: item.priority,
            dueDate: item.dueDate
        )
    }
}
