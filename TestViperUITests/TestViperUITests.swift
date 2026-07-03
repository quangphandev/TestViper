//
//  TestViperUITests.swift
//  TestViperUITests
//
//  ╔══════════════════════════════════════════════════════════════╗
//  ║  UI TESTS: TodoList Screen                                   ║
//  ╚══════════════════════════════════════════════════════════════╝
//
//  UI Tests tương tác với app như người dùng thực sự.
//  Chúng kiểm tra toàn bộ luồng từ View → Presenter → Interactor → View.
//
//  Quan trọng:
//    - Dùng accessibilityIdentifier để tìm elements (không dùng label text cứng)
//    - Dùng waitForExistence(timeout:) thay vì sleep() — robust hơn
//    - continueAfterFailure = false để dừng ngay khi có lỗi
//
//  Chạy: make test-ui hoặc Cmd+U trong Xcode
//

import XCTest

final class TestViperUITests: XCTestCase {

    var app: XCUIApplication!

    // MARK: - Setup

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Truyền flag để biết đang chạy UI test (có thể dùng để mock data)
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Launch Tests
    // ─────────────────────────────────────────────────────────────

    /// App phải khởi động và hiển thị navigation title
    @MainActor
    func testAppLaunches_showsNavigationTitle() throws {
        // Navigation title "My Todos" phải tồn tại
        let navTitle = app.navigationBars.staticTexts["My Todos"]
        XCTAssertTrue(
            navTitle.waitForExistence(timeout: 3),
            "Navigation title 'My Todos' không xuất hiện sau khi app launch"
        )
    }

    /// Khi mới khởi động (in-memory, chưa có data), empty state phải hiển thị
    @MainActor
    func testEmptyState_visibleOnFreshLaunch() throws {
        let emptyState = app.otherElements["emptyStateView"]
        XCTAssertTrue(
            emptyState.waitForExistence(timeout: 3),
            "Empty state phải hiển thị khi danh sách trống"
        )
    }

    /// Input text field phải tồn tại và có thể tương tác
    @MainActor
    func testInputTextField_existsAndInteractable() throws {
        let textField = app.textFields["todoInputTextField"]
        XCTAssertTrue(
            textField.waitForExistence(timeout: 3),
            "Input text field phải tồn tại"
        )
        XCTAssertTrue(textField.isEnabled, "Input text field phải enabled")
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Add Todo Tests
    // ─────────────────────────────────────────────────────────────

    /// Thêm todo hợp lệ → item phải xuất hiện trong table
    @MainActor
    func testAddTodo_withValidTitle_appearsInList() throws {
        let textField = app.textFields["todoInputTextField"]
        let addButton = app.buttons["addTodoButton"]

        XCTAssertTrue(textField.waitForExistence(timeout: 3))

        // Gõ todo mới
        textField.tap()
        textField.typeText("Mua sữa tươi")

        // Tap add
        addButton.tap()

        // Item phải xuất hiện trong table view
        let tableView = app.tables["todoListTableView"]
        XCTAssertTrue(
            tableView.waitForExistence(timeout: 3),
            "Table view phải hiển thị sau khi thêm todo"
        )

        // Text của item mới phải có trong table
        let addedCell = tableView.staticTexts["Mua sữa tươi"]
        XCTAssertTrue(
            addedCell.waitForExistence(timeout: 3),
            "Todo 'Mua sữa tươi' phải xuất hiện sau khi thêm"
        )
    }

    /// Sau khi thêm todo, input field phải rỗng (UX: ready for next input)
    @MainActor
    func testAddTodo_clearsInputFieldAfterAdding() throws {
        let textField = app.textFields["todoInputTextField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 3))

        textField.tap()
        textField.typeText("Test todo")
        app.buttons["addTodoButton"].tap()

        // TextField phải rỗng sau khi thêm
        let value = textField.value as? String ?? ""
        XCTAssertTrue(
            value.isEmpty || value == textField.placeholderValue,
            "Input field phải rỗng sau khi thêm todo"
        )
    }

    /// Thêm todo bằng Return key (keyboard)
    @MainActor
    func testAddTodo_usingReturnKey() throws {
        let textField = app.textFields["todoInputTextField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 3))

        textField.tap()
        textField.typeText("Todo qua Return key")

        // Nhấn Return key trên keyboard
        app.keyboards.buttons["return"].tap()

        let tableView = app.tables["todoListTableView"]
        let addedCell = tableView.staticTexts["Todo qua Return key"]
        XCTAssertTrue(
            addedCell.waitForExistence(timeout: 3),
            "Todo thêm bằng Return key phải xuất hiện"
        )
    }

    /// Thêm nhiều todos — tất cả phải xuất hiện
    @MainActor
    func testAddMultipleTodos_allAppearInList() throws {
        let textField = app.textFields["todoInputTextField"]
        let addButton = app.buttons["addTodoButton"]
        XCTAssertTrue(textField.waitForExistence(timeout: 3))

        let todos = ["Học VIPER", "Viết unit tests", "Review code"]

        for todo in todos {
            textField.tap()
            textField.typeText(todo)
            addButton.tap()
            // Chờ item xuất hiện trước khi thêm cái tiếp theo
            XCTAssertTrue(
                app.tables["todoListTableView"].staticTexts[todo].waitForExistence(timeout: 3)
            )
        }

        // Kiểm tra tất cả đều có
        let table = app.tables["todoListTableView"]
        for todo in todos {
            XCTAssertTrue(
                table.staticTexts[todo].exists,
                "'\(todo)' phải tồn tại trong list"
            )
        }
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Delete Todo Tests
    // ─────────────────────────────────────────────────────────────

    /// Swipe to delete — item phải biến mất khỏi list
    @MainActor
    func testDeleteTodo_byTrailingSwipe_removesFromList() throws {
        // Setup: thêm 1 todo trước
        try addTodo(title: "Todo cần xóa")

        let table = app.tables["todoListTableView"]
        let cell = table.cells.firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 3))

        // Swipe left để reveal delete button
        cell.swipeLeft()

        // Tap delete button (trash icon)
        let deleteButton = table.buttons["Delete"]
        if deleteButton.waitForExistence(timeout: 2) {
            deleteButton.tap()
        } else {
            // Fallback: swipe full để commit delete
            cell.swipeLeft(velocity: .fast)
        }

        // Verify: todo không còn trong list
        let deletedText = table.staticTexts["Todo cần xóa"]
        XCTAssertFalse(
            deletedText.waitForExistence(timeout: 2),
            "Todo đã xóa không được còn trong list"
        )
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Toggle Complete Tests
    // ─────────────────────────────────────────────────────────────

    /// Leading swipe (toggle) → status text phải thay đổi
    @MainActor
    func testToggleTodo_byLeadingSwipe_changesStatus() throws {
        try addTodo(title: "Todo cần toggle")

        let table = app.tables["todoListTableView"]
        let cell = table.cells.firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 3))

        // Swipe right để toggle
        cell.swipeRight()

        // Tap nút toggle (có thể là "Xong" hoặc icon)
        let toggleButton = table.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Xong' OR label CONTAINS 'Toggle'")
        ).firstMatch

        if toggleButton.waitForExistence(timeout: 2) {
            toggleButton.tap()
        }

        // Verify: status text thay đổi
        // "✓ Hoàn thành" phải xuất hiện
        let completedStatus = cell.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Hoàn thành'")
        ).firstMatch
        XCTAssertTrue(
            completedStatus.waitForExistence(timeout: 3),
            "Status phải thay đổi sang 'Hoàn thành' sau khi toggle"
        )
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Navigation Tests
    // ─────────────────────────────────────────────────────────────

    /// Tap vào cell → màn hình Detail phải mở
    @MainActor
    func testTapTodo_navigatesToDetailScreen() throws {
        try addTodo(title: "Todo để xem chi tiết")

        let table = app.tables["todoListTableView"]
        let cell = table.cells.firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 3))

        cell.tap()

        // Detail screen phải có navigation title "Chi tiết"
        let detailTitle = app.navigationBars.staticTexts["Chi tiết"]
        XCTAssertTrue(
            detailTitle.waitForExistence(timeout: 3),
            "Navigation title 'Chi tiết' phải xuất hiện trên Detail screen"
        )

        // Title label trong detail phải khớp
        let detailLabel = app.staticTexts["detailTitleLabel"]
        XCTAssertTrue(
            detailLabel.waitForExistence(timeout: 3),
            "Detail title label phải tồn tại"
        )
    }

    /// Từ Detail, back về List phải hoạt động
    @MainActor
    func testNavigateBack_fromDetailToList() throws {
        try addTodo(title: "Todo để test back")

        let table = app.tables["todoListTableView"]
        table.cells.firstMatch.tap()

        // Verify đang ở Detail
        XCTAssertTrue(
            app.navigationBars.staticTexts["Chi tiết"].waitForExistence(timeout: 3)
        )

        // Tap back button
        app.navigationBars.buttons.firstMatch.tap()

        // Verify đã về List
        XCTAssertTrue(
            app.navigationBars.staticTexts["My Todos"].waitForExistence(timeout: 3),
            "Phải về List screen sau khi back"
        )
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Performance Tests
    // ─────────────────────────────────────────────────────────────

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Private Helpers
    // ─────────────────────────────────────────────────────────────

    /// Helper: thêm 1 todo item nhanh
    private func addTodo(title: String) throws {
        let textField = app.textFields["todoInputTextField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 3))

        textField.tap()
        textField.typeText(title)
        app.buttons["addTodoButton"].tap()

        // Đợi item xuất hiện
        XCTAssertTrue(
            app.tables["todoListTableView"].staticTexts[title].waitForExistence(timeout: 3),
            "Todo '\(title)' phải xuất hiện sau khi thêm"
        )
    }
}
