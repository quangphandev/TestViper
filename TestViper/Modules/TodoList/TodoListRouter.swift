//
//  TodoListRouter.swift
//  TestViper
//
//  ╔══════════════════════════════════════════╗
//  ║  VIPER Layer: ROUTER                     ║
//  ╚══════════════════════════════════════════╝
//
//  Router đảm nhiệm 2 việc:
//  1. ASSEMBLY: tạo + kết nối toàn bộ VIPER layers
//  2. NAVIGATION: điều hướng sang màn hình khác
//
//  Bug Fix: Router giữ shared repository instance để truyền
//  sang TodoDetailRouter khi navigate. Đảm bảo List và Detail
//  dùng CÙNG một data source.
//

import UIKit

// MARK: - TodoListRouter

final class TodoListRouter {

    weak var viewController: UIViewController?

    /// Shared repository — truyền sang Detail khi navigate
    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Module Assembly

    static func createModule() -> UIViewController {
        // ✅ UserDefaultsTodoRepository — data persist khi app restart
        let repository = UserDefaultsTodoRepository()

        let view       = TodoListViewController()
        let presenter  = TodoListPresenter()
        let interactor = TodoListInteractor(repository: repository)
        let router     = TodoListRouter(repository: repository)

        // Wire-up View ↔ Presenter
        view.presenter      = presenter
        presenter.view      = view

        // Wire-up Presenter ↔ Interactor
        presenter.interactor = interactor
        interactor.output    = presenter

        // Wire-up Presenter ↔ Router
        presenter.router     = router
        router.viewController = view

        let navController = UINavigationController(rootViewController: view)
        return navController
    }
}

// MARK: - TodoListRouterInput

extension TodoListRouter: TodoListRouterInput {

    func navigateToDetail(with item: TodoItem) {
        // ✅ Bug Fix: truyền cùng repository instance → Detail ghi vào cùng store
        let detailVC = TodoDetailRouter.createModule(with: item, repository: repository)
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
}
