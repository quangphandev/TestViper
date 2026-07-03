//
//  TodoDetailUITests.swift
//  TestViperUITests
//
//  ╔══════════════════════════════════════════════════════════════╗
//  ║  UI TESTS: TodoDetail Screen                                 ║
//  ╚══════════════════════════════════════════════════════════════╝
//
//  Test màn hình Detail: hiển thị thông tin, toggle complete button.
//

import XCTest

final class TodoDetailUITests: XCTestCase {

    var app: XCUIApplication!

    // MARK: - Setup

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Detail Display Tests
    // ─────────────────────────────────────────────────────────────

    /// Detail screen hiển thị đúng title của todo đã tap
    @MainActor
    func testDetailScreen_showsCorrectTodoTitle() throws {
        let todoTitle = "Detail Test: Học SwiftUI"
        try navigateToDetail(todoTitle: todoTitle)

        // Title label trong detail phải match với todo đã tap
        let detailTitleLabel = app.staticTexts["detailTitleLabel"]
        XCTAssertTrue(
            detailTitleLabel.waitForExistence(timeout: 3),
            "Detail title label phải tồn tại"
        )
        XCTAssertEqual(
            detailTitleLabel.label,
            todoTitle,
            "Title trong Detail phải khớp với title todo đã chọn"
        )
    }

    /// Detail screen phải hiển thị navigation title "Chi tiết"
    @MainActor
    func testDetailScreen_showsNavigationTitle() throws {
        try navigateToDetail(todoTitle: "Nav Title Test")

        XCTAssertTrue(
            app.navigationBars.staticTexts["Chi tiết"].waitForExistence(timeout: 3),
            "Navigation title 'Chi tiết' phải xuất hiện"
        )
    }

    /// Toggle Complete button phải tồn tại trên Detail screen
    @MainActor
    func testDetailScreen_toggleCompleteButton_exists() throws {
        try navigateToDetail(todoTitle: "Toggle Button Test")

        let toggleButton = app.buttons["toggleCompleteButton"]
        XCTAssertTrue(
            toggleButton.waitForExistence(timeout: 3),
            "Toggle Complete button phải tồn tại trên Detail screen"
        )
        XCTAssertTrue(toggleButton.isEnabled, "Toggle button phải enabled")
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Toggle Button Tests
    // ─────────────────────────────────────────────────────────────

    /// Tap Toggle button → button title phải thay đổi (phản ánh state mới)
    @MainActor
    func testToggleButton_tapChangesButtonTitle() throws {
        try navigateToDetail(todoTitle: "Toggle State Test")

        let toggleButton = app.buttons["toggleCompleteButton"]
        XCTAssertTrue(toggleButton.waitForExistence(timeout: 3))

        // Initial: chưa hoàn thành → button phải chứa "Hoàn thành"
        let initialTitle = toggleButton.label
        XCTAssertTrue(
            initialTitle.contains("Hoàn thành") || initialTitle.contains("hoàn thành"),
            "Button title ban đầu phải đề cập đến 'Hoàn thành'"
        )

        // Tap toggle
        toggleButton.tap()

        // Sau toggle: button phải thay đổi title
        // Đợi UI update
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "label CONTAINS 'chưa xong' OR label CONTAINS 'Bỏ'"),
            object: toggleButton
        )
        let result = XCTWaiter.wait(for: [expectation], timeout: 3)
        XCTAssertEqual(result, .completed, "Button title phải thay đổi sau khi toggle")
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Private Helpers
    // ─────────────────────────────────────────────────────────────

    /// Helper: thêm todo rồi navigate vào Detail
    private func navigateToDetail(todoTitle: String) throws {
        // Thêm todo
        let textField = app.textFields["todoInputTextField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 3))
        textField.tap()
        textField.typeText(todoTitle)
        app.buttons["addTodoButton"].tap()

        // Đợi item xuất hiện
        let table = app.tables["todoListTableView"]
        let cell = table.cells.firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 3))

        // Tap để vào Detail
        cell.tap()

        // Verify đang ở Detail
        XCTAssertTrue(
            app.navigationBars.staticTexts["Chi tiết"].waitForExistence(timeout: 3),
            "Phải navigate sang Detail screen"
        )
    }
}
