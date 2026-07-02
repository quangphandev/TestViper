//
//  TodoDetailRouter.swift
//  TestViper
//
//  Router của TodoDetail:
//  Nhận TodoItem như một dependency khi tạo module.
//  Đây là cách VIPER truyền data giữa các màn hình — qua Router.
//

import UIKit

final class TodoDetailRouter {
    weak var viewController: UIViewController?
}

extension TodoDetailRouter: TodoDetailRouterInput {

    /// Tạo module với item cụ thể — được gọi bởi TodoListRouter
    static func createModule(with item: TodoItem) -> UIViewController {
        let view = TodoDetailViewController()
        let presenter = TodoDetailPresenter()
        // Item được inject vào Interactor — không qua View
        let interactor = TodoDetailInteractor(item: item)
        let router = TodoDetailRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        interactor.output = presenter
        presenter.router = router
        router.viewController = view

        return view
    }
}
