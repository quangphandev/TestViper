//
//  MockTodoDetailView.swift
//  TestViperTests
//

import UIKit
@testable import TestViper

final class MockTodoDetailView: TodoDetailPresenterOutput {

    private(set) var displayTodoCallCount = 0
    private(set) var lastTitle: String?
    private(set) var lastStatus: String?
    private(set) var lastStatusColor: UIColor?
    private(set) var lastDate: String?
    private(set) var lastIsCompleted: Bool?
    private(set) var lastPriority: Priority?
    private(set) var lastDueDate: Date?

    func displayTodo(
        title: String,
        status: String,
        statusColor: UIColor,
        date: String,
        isCompleted: Bool,
        priority: Priority,
        dueDate: Date?
    ) {
        displayTodoCallCount += 1
        lastTitle = title
        lastStatus = status
        lastStatusColor = statusColor
        lastDate = date
        lastIsCompleted = isCompleted
        lastPriority = priority
        lastDueDate = dueDate
    }
}
