//
//  TodoDetailPresenter.swift
//  TestViper
//
//  Presenter của TodoDetail: nhận item từ Interactor → format → bảo View hiển thị.
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
}

extension TodoDetailPresenter: TodoDetailInteractorOutput {
    func didFetchTodo(_ item: TodoItem) {
        // Format date
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMMM yyyy 'lúc' HH:mm"
        formatter.locale = Locale(identifier: "vi_VN")
        let dateText = formatter.string(from: item.createdAt)

        let status = item.isCompleted ? "✅ Đã hoàn thành" : "🔵 Đang thực hiện"
        let statusColor: UIColor = item.isCompleted ? .systemGreen : .systemBlue

        view?.displayTodo(
            title: item.title,
            status: status,
            statusColor: statusColor,
            date: dateText
        )
    }
}
