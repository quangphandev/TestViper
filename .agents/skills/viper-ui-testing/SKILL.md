---
name: viper-ui-testing
description: >
  Hướng dẫn viết UI Tests (XCTest) cho màn hình VIPER trong iOS.
  Áp dụng khi cần test View layer, user flows, hoặc end-to-end scenarios.
  Bao gồm: accessibilityIdentifier pattern, Page Object Model, 
  waitForExistence, và phân biệt khi nào dùng UI Test vs Snapshot Test.
---

# VIPER UI Testing — Skill Guide

## Tổng quan

Trong VIPER, View layer được test bằng **UI Tests** (XCTest / XCUITest) vì:
- View là "dumb view" — không có logic để unit test
- Cần kiểm tra tương tác thực sự: tap, swipe, type text, navigation
- UI Tests chạy trên simulator với app thật, đảm bảo end-to-end flow

---

## 1. Đặt `accessibilityIdentifier` đúng cách

### Quy tắc đặt tên

```swift
// Format: <context>_<elementType>_<description>
// hoặc: <elementType><PascalCase>

// ✅ Đúng — rõ ràng, unique, không phụ thuộc text hiển thị
textField.accessibilityIdentifier = "todoInputTextField"
button.accessibilityIdentifier = "addTodoButton"
tableView.accessibilityIdentifier = "todoListTableView"
emptyStateView.accessibilityIdentifier = "emptyStateView"
label.accessibilityIdentifier = "detailTitleLabel"

// Dynamic ID cho cells (dùng UUID để unique)
cell.accessibilityIdentifier = "todoCell_\(viewModel.id)"

// ❌ Sai — phụ thuộc vào text hiển thị (dễ break khi thay đổi UI)
button.accessibilityIdentifier = "Thêm"
label.accessibilityIdentifier = "My Todos 📋"
```

### Nơi đặt identifier

```swift
// ✅ Đặt trong setupCell() / setupUI() — một lần duy nhất
private func setupUI() {
    tableView.accessibilityIdentifier = "todoListTableView"
    addButton.accessibilityIdentifier = "addTodoButton"
    emptyStateView.accessibilityIdentifier = "emptyStateView"
}

// Với cells: đặt trong configure(with:)
func configure(with viewModel: TodoViewModel) {
    accessibilityIdentifier = "todoCell_\(viewModel.id)"
}
```

---

## 2. Tìm elements trong UI Tests

### Các cách tìm elements

```swift
let app = XCUIApplication()

// Tìm theo accessibilityIdentifier (ưu tiên)
let textField = app.textFields["todoInputTextField"]
let button    = app.buttons["addTodoButton"]
let table     = app.tables["todoListTableView"]
let label     = app.staticTexts["detailTitleLabel"]
let view      = app.otherElements["emptyStateView"]

// Tìm theo label text (fallback — tránh dùng nếu có thể)
let navTitle = app.navigationBars.staticTexts["My Todos"]

// Tìm bằng predicate (flexible)
let toggleBtn = app.buttons.matching(
    NSPredicate(format: "label CONTAINS 'Hoàn thành'")
).firstMatch

// Tìm cell đầu tiên
let firstCell = table.cells.firstMatch
```

### Hierarchy element types

| Element | XCUIElement type |
|---|---|
| UIButton | `app.buttons["id"]` |
| UITextField | `app.textFields["id"]` |
| UILabel | `app.staticTexts["id"]` |
| UITableView | `app.tables["id"]` |
| UITableViewCell | `table.cells["id"]` |
| UIView (generic) | `app.otherElements["id"]` |
| UINavigationBar | `app.navigationBars["title"]` |
| UISwitch | `app.switches["id"]` |

---

## 3. `waitForExistence` — Best Practice

**KHÔNG bao giờ dùng `sleep()` để chờ.** Dùng `waitForExistence(timeout:)`:

```swift
// ✅ Đúng — đợi element xuất hiện, timeout sau 3 giây
let button = app.buttons["addTodoButton"]
XCTAssertTrue(button.waitForExistence(timeout: 3))

// ✅ Đúng — đợi condition với NSPredicate
let expectation = XCTNSPredicateExpectation(
    predicate: NSPredicate(format: "label CONTAINS 'Hoàn thành'"),
    object: button
)
let result = XCTWaiter.wait(for: [expectation], timeout: 5)
XCTAssertEqual(result, .completed)

// ❌ Sai — cứng nhắc, flaky
Thread.sleep(forTimeInterval: 2)
sleep(2)
```

**Timeout recommendations:**
- App launch / navigation: `timeout: 5`
- UI update sau action: `timeout: 3`
- Animation nhỏ: `timeout: 1`

---

## 4. Pattern: Helper Methods

Tạo helper methods để tái sử dụng setup code:

```swift
final class TodoListUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }
    
    // ─── Helper ───
    
    /// Thêm todo item vào list
    private func addTodo(title: String) throws {
        let textField = app.textFields["todoInputTextField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 3))
        textField.tap()
        textField.typeText(title)
        app.buttons["addTodoButton"].tap()
        XCTAssertTrue(
            app.tables["todoListTableView"].staticTexts[title].waitForExistence(timeout: 3)
        )
    }
    
    // ─── Tests ───
    
    func testDeleteTodo() throws {
        try addTodo(title: "Todo cần xóa")  // Reuse helper
        // ... test logic ...
    }
}
```

---

## 5. Pattern: Page Object Model (POM)

Cho app lớn hơn, tách logic tìm elements vào Page Objects:

```swift
// Pages/TodoListPage.swift
struct TodoListPage {
    let app: XCUIApplication
    
    var inputTextField: XCUIElement { app.textFields["todoInputTextField"] }
    var addButton: XCUIElement { app.buttons["addTodoButton"] }
    var tableView: XCUIElement { app.tables["todoListTableView"] }
    var emptyState: XCUIElement { app.otherElements["emptyStateView"] }
    
    @discardableResult
    func addTodo(title: String) -> Self {
        inputTextField.tap()
        inputTextField.typeText(title)
        addButton.tap()
        return self
    }
    
    func cell(at index: Int) -> XCUIElement {
        tableView.cells.element(boundBy: index)
    }
}

// Dùng trong tests:
func testAddTodo() throws {
    let page = TodoListPage(app: app)
    page.addTodo(title: "Học POM")
    XCTAssertTrue(page.tableView.staticTexts["Học POM"].waitForExistence(timeout: 3))
}
```

---

## 6. Launch Arguments để Mock Data

Khi UI test cần data đã có sẵn (không muốn phụ thuộc vào state trước):

```swift
// Trong UI Test
app.launchArguments = ["UI_TESTING", "RESET_DATA"]
app.launch()

// Trong AppDelegate / SceneDelegate
if CommandLine.arguments.contains("RESET_DATA") {
    // Reset in-memory store hoặc inject mock data
}

if CommandLine.arguments.contains("UI_TESTING") {
    // Tắt animations để test nhanh hơn
    UIView.setAnimationsEnabled(false)
}
```

---

## 7. Khi nào dùng UI Test vs Snapshot Test

| Tiêu chí | UI Test (XCUITest) | Snapshot Test (iOSSnapshotTestCase) |
|---|---|---|
| **Mục đích** | Test behavior / interactions | Test visual appearance |
| **Tốc độ** | Chậm (cần simulator) | Nhanh (không cần simulator) |
| **Flakiness** | Có thể flaky | Ổn định hơn |
| **Dùng khi** | Add/delete/navigate flows | Pixel-perfect UI regression |
| **Maintenance** | Trung bình | Cần update khi UI thay đổi |

**Trong VIPER:**
- ✅ UI Tests: test các flows qua nhiều screens (navigate, interact)
- ✅ Snapshot: test layout của từng View component
- ✅ Unit Tests: test Presenter, Interactor (không cần UI)

---

## 8. Tránh các Pitfalls phổ biến

```swift
// ❌ Không test bằng label text — sẽ break khi thay đổi copy
app.buttons["Thêm"].tap()

// ✅ Dùng accessibilityIdentifier
app.buttons["addTodoButton"].tap()

// ❌ Hard-code wait
Thread.sleep(forTimeInterval: 2)

// ✅ waitForExistence
XCTAssertTrue(element.waitForExistence(timeout: 3))

// ❌ Không reset state giữa các tests
// State cũ từ test trước có thể ảnh hưởng

// ✅ Launch app fresh trong setUp
override func setUpWithError() throws {
    app = XCUIApplication()
    app.launch()
}

// ❌ Không set continueAfterFailure = true trong UI tests
// (Nên false để dừng sớm khi fail)

// ✅ 
continueAfterFailure = false
```

---

## 9. Makefile commands

```bash
make test-ui        # Chỉ chạy UI tests
make test-unit      # Chỉ chạy unit tests (nhanh, không cần simulator bật)
make test           # Tất cả tests
make ci             # Build + test (full pipeline)
```
