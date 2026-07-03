//
//  TodoDetailRouter.swift
//  TestViper
//
//  ✅ Bug Fix: nhận shared repository từ TodoListRouter
//  để inject vào TodoDetailInteractor.
//

import UIKit

final class TodoDetailRouter {
    weak var viewController: UIViewController?
}

extension TodoDetailRouter: TodoDetailRouterInput {

    static func createModule(with item: TodoItem, repository: TodoRepositoryProtocol) -> UIViewController {
        let view       = TodoDetailViewController()
        let presenter  = TodoDetailPresenter()
        // ✅ Inject cùng repository instance
        let interactor = TodoDetailInteractor(item: item, repository: repository)
        let router     = TodoDetailRouter()

        view.presenter      = presenter
        presenter.view      = view
        presenter.interactor = interactor
        interactor.output   = presenter
        presenter.router    = router
        router.viewController = view

        return view
    }
}
