//
//  TodoListRouter.swift
//  TestViper
//
//  ╔══════════════════════════════════════════╗
//  ║  VIPER Layer: ROUTER                     ║
//  ╚══════════════════════════════════════════╝
//
//  Router đảm nhiệm 2 việc quan trọng:
//
//  1. ASSEMBLY (Wire-up):
//     Tạo và kết nối tất cả các layer VIPER với nhau.
//     Đây là nơi DUY NHẤT biết về tất cả các layer.
//
//  2. NAVIGATION:
//     Điều hướng sang màn hình khác.
//     Presenter KHÔNG biết cách navigate — nó chỉ gọi router.
//
//  Pattern phổ biến: static func createModule() → UIViewController
//  Caller chỉ cần gọi một dòng để có màn hình hoàn chỉnh.
//

import UIKit

// MARK: - TodoListRouter

final class TodoListRouter {

    // Router giữ weak ref đến View Controller để push/present
    weak var viewController: UIViewController?

    // MARK: - Module Assembly (createModule)

    /// Đây là "constructor" của toàn bộ VIPER module.
    /// Chỉ gọi một lần khi khởi tạo màn hình.
    ///
    /// Wire-up order:
    /// 1. Tạo tất cả các objects
    /// 2. Kết nối chúng lại với nhau
    static func createModule() -> UIViewController {

        // 1. Tạo từng layer
        let view = TodoListViewController()
        let presenter = TodoListPresenter()
        let interactor = TodoListInteractor()
        let router = TodoListRouter()

        // 2. Kết nối View ↔ Presenter
        view.presenter = presenter         // View gọi Presenter qua PresenterInput
        presenter.view = view              // Presenter update View qua PresenterOutput

        // 3. Kết nối Presenter ↔ Interactor
        presenter.interactor = interactor  // Presenter gọi Interactor qua InteractorInput
        interactor.output = presenter      // Interactor trả kết quả về Presenter qua InteractorOutput

        // 4. Kết nối Presenter ↔ Router
        presenter.router = router          // Presenter điều hướng qua RouterInput
        router.viewController = view       // Router cần VC để push/present

        // 5. Wrap trong NavigationController
        let navController = UINavigationController(rootViewController: view)
        return navController
    }
}

// MARK: - TodoListRouterInput

extension TodoListRouter: TodoListRouterInput {

    func navigateToDetail(with item: TodoItem) {
        // Tạo màn hình Detail thông qua Router của nó
        let detailVC = TodoDetailRouter.createModule(with: item)

        // Push — cần unwrap navigationController từ viewController
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
}
