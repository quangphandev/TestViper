//
//  TodoItem.swift
//  TestViper
//
//  ╔══════════════════════════════════════════╗
//  ║  VIPER Layer: ENTITY                     ║
//  ╚══════════════════════════════════════════╝
//
//  Entity là tầng DATA thuần tuý trong VIPER.
//  Quy tắc vàng của Entity:
//    ✅ Chỉ chứa data (properties)
//    ✅ Không có business logic
//    ✅ Không biết UI, không biết mạng, không biết DB
//    ✅ Dùng struct vì data là value type (copy-on-write, thread-safe hơn)
//
//  Entity này được tạo bởi Interactor và chuyển qua Presenter.
//  Presenter KHÔNG hiển thị Entity trực tiếp lên View — nó sẽ
//  format thành ViewModel trước (xem TodoListPresenter.swift).
//

import Foundation

// MARK: - TodoItem Entity

/// Đại diện cho một todo item trong hệ thống.
/// Đây là "nguồn sự thật" (source of truth) của dữ liệu.
struct TodoItem {

    // UUID giúp mỗi item có ID duy nhất, an toàn khi xoá/update
    let id: UUID

    var title: String
    var isCompleted: Bool

    // Immutable: ngày tạo không bao giờ thay đổi
    let createdAt: Date

    /// Khởi tạo với default values để tiện dùng
    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

// MARK: - Equatable
// Cần thiết để so sánh trong unit test và tìm kiếm trong array
extension TodoItem: Equatable {
    static func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        // So sánh bằng ID vì ID là định danh duy nhất
        lhs.id == rhs.id
    }
}
