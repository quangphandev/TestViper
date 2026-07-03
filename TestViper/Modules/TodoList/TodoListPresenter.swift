//
//  TodoListPresenter.swift
//  TestViper
//
//  ╔══════════════════════════════════════════╗
//  ║  VIPER Layer: PRESENTER                  ║
//  ╚══════════════════════════════════════════╝
//

import UIKit

// MARK: - TodoListPresenter

final class TodoListPresenter {

    weak var view: TodoListPresenterOutput?
    var interactor: TodoListInteractorInput?
    var router: TodoListRouterInput?

    // Source of truth: tất cả items từ repository
    private var currentItems: [TodoItem] = []

    // Search & Filter state
    private var searchQuery: String = ""
    private var currentFilter: FilterType = .all

    // MARK: - Computed: filtered items (dùng để map index → id)

    /// Items sau khi áp dụng filter + search.
    /// View chỉ nhận danh sách này — index trong View tương ứng với index ở đây.
    private var filteredItems: [TodoItem] {
        currentItems.filter { item in
            let matchesFilter: Bool
            switch currentFilter {
            case .all:       matchesFilter = true
            case .pending:   matchesFilter = !item.isCompleted
            case .completed: matchesFilter = item.isCompleted
            }
            let matchesSearch = searchQuery.isEmpty
                || item.title.localizedCaseInsensitiveContains(searchQuery)
            return matchesFilter && matchesSearch
        }
    }

    // MARK: - Private Helpers

    /// Format TodoItem → TodoViewModel (presentation logic, không phải business logic)
    private func makeViewModel(from item: TodoItem) -> TodoViewModel {
        // Created date
        let createdFormatter = DateFormatter()
        createdFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let dateText = createdFormatter.string(from: item.createdAt)

        // Status
        let statusText = item.isCompleted ? "✓ Hoàn thành" : "○ Chưa xong"
        let statusColor: UIColor = item.isCompleted ? AppTheme.Color.success : AppTheme.Color.warning

        // Due date
        let (dueDateText, isOverdue) = formatDueDate(item.dueDate, isCompleted: item.isCompleted)

        return TodoViewModel(
            id: item.id,
            title: item.title,
            statusText: statusText,
            statusColor: statusColor,
            isCompleted: item.isCompleted,
            priorityColor: item.priority.color,
            priorityText: item.priority.displayText,
            dueDateText: dueDateText,
            isOverdue: isOverdue,
            dateText: dateText
        )
    }

    private func formatDueDate(_ date: Date?, isCompleted: Bool) -> (text: String?, isOverdue: Bool) {
        guard let date else { return (nil, false) }
        let now = Date()
        let isOverdue = date < now && !isCompleted
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")

        if isOverdue {
            formatter.dateFormat = "'⚠️ Quá hạn' dd/MM"
        } else if calendar.isDateInToday(date) {
            formatter.dateFormat = "'Hôm nay' HH:mm"
        } else if calendar.isDateInTomorrow(date) {
            formatter.dateFormat = "'Ngày mai' HH:mm"
        } else {
            formatter.dateFormat = "dd/MM/yyyy"
        }

        return (formatter.string(from: date), isOverdue)
    }

    /// Render filteredItems → gửi lên View
    private func refreshView() {
        let viewModels = filteredItems.map { makeViewModel(from: $0) }
        view?.displayTodos(viewModels)
    }
}

// MARK: - TodoListPresenterInput

extension TodoListPresenter: TodoListPresenterInput {

    func viewDidLoad() {
        view?.displayLoading(true)
        interactor?.fetchTodos()
    }

    /// ✅ Bug Fix: gọi khi View appear lại — refresh từ repo để sync với Detail
    func viewWillAppear() {
        interactor?.fetchTodos()
    }

    func didTapAddTodo(title: String) {
        interactor?.addTodo(title: title)
    }

    func didTapDeleteTodo(at index: Int) {
        guard index < filteredItems.count else { return }
        interactor?.deleteTodo(id: filteredItems[index].id)
    }

    func didSelectTodo(at index: Int) {
        guard index < filteredItems.count else { return }
        router?.navigateToDetail(with: filteredItems[index])
    }

    func didToggleComplete(at index: Int) {
        guard index < filteredItems.count else { return }
        interactor?.toggleComplete(id: filteredItems[index].id)
    }

    func didEditTodo(at index: Int, newTitle: String) {
        guard index < filteredItems.count else { return }
        interactor?.editTodo(id: filteredItems[index].id, newTitle: newTitle)
    }

    func didSearch(query: String) {
        searchQuery = query
        refreshView()
    }

    func didSelectFilter(_ filter: FilterType) {
        currentFilter = filter
        refreshView()
    }
}

// MARK: - TodoListInteractorOutput

extension TodoListPresenter: TodoListInteractorOutput {

    func didFetchTodos(_ items: [TodoItem]) {
        currentItems = items
        view?.displayLoading(false)
        refreshView()
    }

    func didAddTodo(_ item: TodoItem) {
        currentItems.append(item)
        refreshView()
    }

    func didDeleteTodo(id: UUID) {
        currentItems.removeAll { $0.id == id }
        refreshView()
    }

    func didToggleComplete(_ item: TodoItem) {
        if let idx = currentItems.firstIndex(where: { $0.id == item.id }) {
            currentItems[idx] = item
        }
        refreshView()
    }

    func didEditTodo(_ item: TodoItem) {
        if let idx = currentItems.firstIndex(where: { $0.id == item.id }) {
            currentItems[idx] = item
        }
        refreshView()
    }

    func didFailWithError(_ error: Error) {
        view?.displayLoading(false)
        view?.displayError(error.localizedDescription)
    }
}
