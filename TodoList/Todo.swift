//
//  Todo.swift
//  TodoList
//
//  Created by LDH on 2021/03/19.
//  Copyright © 2021 com.joonwon. All rights reserved.
//

import UIKit


// TODO: Codable과 Equatable 추가
struct Todo: Codable, Equatable { // 동등 비교를 하기 위해서는 사용해야할 프로토콜이다.
    let id: Int
    var isDone: Bool
    var detail: String
    var isToday: Bool
    
    mutating func update(isDone: Bool, detail: String, isToday: Bool) { // mutating -> 자기자신의 값을 스스로 바꾸는구나 싶은걸 예측
        // [X] TODO: update 로직 추가
        self.isDone = isDone
        self.detail = detail
        self.isToday = isToday
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool { // == 함수는 나중에 투두에 업데이트를 할 때
        // [X] TODO: 동등 조건 추가
        return lhs.id == rhs.id
    }
}

class TodoManager { // 관리하는 메서드, 객체, 여러개의 투두 관리
    
    static let shared = TodoManager() // 싱글톤 객체
    
    static var lastId: Int = 0 // 새로운 태스크를 만들때 제작
    
    var todos: [Todo] = [] // 여러개의 투두 알고있어야 함.
    
    func createTodo(detail: String, isToday: Bool) -> Todo { // 투두 객체 제작
        // [X] TODO: create로직 추가
        let nextId = TodoManager.lastId + 1
        TodoManager.lastId = nextId
        return Todo(id: nextId, isDone: false, detail: detail, isToday: isToday)
    }
    
    func addTodo(_ todo: Todo) {
        // [X] TODO: add로직 추가
        todos.append(todo)
        saveTodo()
    }
    
    func deleteTodo(_ todo: Todo) {
        // [X] TODO: delete 로직 추가
        
//        todos = todos.filter { existingTodo in
//            return existingTodo.id != todo.id
//        }
        todos = todos.filter{ $0.id != todo.id } // 위의 코드랑 같은 코드임
        
//        if let index = todos.firstIndex(of: todo) { // 알고리즘 상 효율적일 수 있음
//            todos.remove(at: index)
//        }
        saveTodo()
    }
    
    func updateTodo(_ todo: Todo) {
        // [X] TODO: updatee 로직 추가
        guard let index = todos.firstIndex(of: todo) else { return }
        todos[index].update(isDone: todo.isDone, detail: todo.detail, isToday: todo.isToday)
        saveTodo()
    }
    
    func saveTodo() {
        Storage.store(todos, to: .documents, as: "todos.json")
    }
    
    func retrieveTodo() {
        todos = Storage.retrive("todos.json", from: .documents, as: [Todo].self) ?? []
        
        let lastId = todos.last?.id ?? 0
        TodoManager.lastId = lastId
    }
}

class TodoViewModel { // todomanager를 사용함 MVVM에서 ㅇㅇ
    
    enum Section: Int, CaseIterable {
        case today
        case upcoming
        
        var title: String {
            switch self {
            case .today: return "Today"
            default: return "Upcoming"
            }
        }
    }
    
    private let manager = TodoManager.shared
    
    var todos: [Todo] {
        return manager.todos
    }
    
    var todayTodos: [Todo] {
        return todos.filter { $0.isToday == true }
    }
    
    var upcompingTodos: [Todo] {
        return todos.filter { $0.isToday == false }
    }
    
    var numOfSection: Int {
        return Section.allCases.count
    }
    
    func addTodo(_ todo: Todo) {
        manager.addTodo(todo)
    }
    
    func deleteTodo(_ todo: Todo) {
        manager.deleteTodo(todo)
    }
    
    func updateTodo(_ todo: Todo) {
        manager.updateTodo(todo)
    }
    
    func loadTasks() {
        manager.retrieveTodo()
    }
}

