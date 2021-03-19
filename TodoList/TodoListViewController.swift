//
//  TodoListViewController.swift
//  TodoList
//
//  Created by LDH on 2021/03/19.
//  Copyright © 2021 com.joonwon. All rights reserved.
//

import UIKit

class TodoListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var inputViewBottom: NSLayoutConstraint!
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var isTodayButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    
    // [X] TODO: TodoViewModel 만들기
    let todoListViewModel = TodoViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: 키보드 디텍션
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
        // TODO: 데이터 불러오기
        todoListViewModel.loadTasks()
        
//        let todo = TodoManager.shared.createTodo(detail: "🧞 힘들다", isToday: true)
//        Storage.saveTodo(todo, fileName: "test.json")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let todo = Storage.restoreTodo("test.json")
//        print("---> restore from disk \(todo)")
    }
    
    @IBAction func isTodayButtonTapped(_ sender: Any) {
        // [X] TODO: 투데이 버튼 토글 작업
        isTodayButton.isSelected = !isTodayButton.isSelected
    }
    
    @IBAction func addTaskButtonTapped(_ sender: Any) {
        // [X] TODO: Todo 태스크 추가
        // add task to view model
        // and tableview reload or update
        guard let detail = inputTextField.text, detail.isEmpty == false else { return }
        let todo = TodoManager.shared.createTodo(detail: detail, isToday: isTodayButton.isSelected)
        
        todoListViewModel.addTodo(todo)
        collectionView.reloadData() // 뷰모델에 새로운 정보 추가
        
        inputTextField.text = "" // 텍스트 필드 초기화
        isTodayButton.isSelected = false
        
    }
    
    // [X] TODO: BG 탭했을때, 키보드 내려오게 하기
    @IBAction func tapBG(_ sender: Any) {
        inputTextField.resignFirstResponder()
    }
}

extension TodoListViewController {
    @objc private func adjustInputView(noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        // [X] TODO: 키보드 높이에 따른 인풋뷰 위치 변경
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if noti.name == UIResponder.keyboardWillShowNotification {
            let adjustmentHeight = keyboardFrame.height - view.safeAreaInsets.bottom
            inputViewBottom.constant = adjustmentHeight
        } else {
            inputViewBottom.constant = 0
        }
    }
}

extension TodoListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // [X] TODO: 섹션 몇개
        return todoListViewModel.numOfSection
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // [X] TODO: 섹션별 아이템 몇개, 각 섹션별로 몇개인지 알려주기
        if section == 0 {
            return todoListViewModel.todayTodos.count
        } else {
            return todoListViewModel.upcompingTodos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // [X] TODO: 커스텀 셀
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodoListCell", for: indexPath) as? TodoListCell else {
            return UICollectionViewCell()
        }
        
        var todo: Todo
        if indexPath.section == 0 {
            todo = todoListViewModel.todayTodos[indexPath.item]
        } else {
            todo = todoListViewModel.upcompingTodos[indexPath.item]
        }
        
        // [X] TODO: todo 를 이용해서 updateUI
        cell.updateUI(todo: todo)
        
        // [X] TODO: doneButtonHandler 작성
        cell.doneButtonTapHandler = { isDone in
            todo.isDone = isDone
            self.todoListViewModel.updateTodo(todo)
            self.collectionView.reloadData()
        }
        
        // [X] TODO: deleteButtonHandler 작성
        cell.deleteButtonTapHandler = {
            self.todoListViewModel.deleteTodo(todo)
            self.collectionView.reloadData()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TodoListHeaderView", for: indexPath) as? TodoListHeaderView else {
                return UICollectionReusableView()
            }
            
            guard let section = TodoViewModel.Section(rawValue: indexPath.section) else {
                return UICollectionReusableView()
            }
            
            header.sectionTitleLabel.text = section.title
            return header
        default:
            return UICollectionReusableView()
        }
    }
}

extension TodoListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // TODO: 사이즈 계산하기, row 한줄로 보여주고자 함
        let width:CGFloat = collectionView.bounds.width
        let height:CGFloat = 50
        
        return CGSize(width: width, height: height)
    }
}

class TodoListCell: UICollectionViewCell {
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var strikeThroughView: UIView! // 높이가 1짜리인 뷰
    
    @IBOutlet weak var strikeThroughWidth: NSLayoutConstraint!
    
    var doneButtonTapHandler: ((Bool) -> Void)?
    var deleteButtonTapHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func updateUI(todo: Todo) {
        // [X] TODO: 셀 업데이트 하기
        checkButton.isSelected = todo.isDone
        descriptionLabel.text = todo.detail
        descriptionLabel.alpha = todo.isDone ? 0.2 : 1
        deleteButton.isHidden = todo.isDone == false
        showStrikeThrough(todo.isDone)
    }
    
    private func showStrikeThrough(_ show: Bool) {
        if show {
            strikeThroughWidth.constant = descriptionLabel.bounds.width
        } else {
            strikeThroughWidth.constant = 0
        }
    }
    
    func reset() { // 재사용하기 위해 구축
        // [X] TODO: reset로직 구현
        descriptionLabel.alpha = 1 // 초기화 세팅하고
        deleteButton.isHidden = true
        showStrikeThrough(false)
    }
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        // [X] TODO: checkButton 처리
        checkButton.isSelected = !checkButton.isSelected
        let isDone = checkButton.isSelected
        showStrikeThrough(isDone)
        descriptionLabel.alpha = isDone ? 0.2 : 1
        deleteButton.isHidden = !isDone
        // View에 관해서
        doneButtonTapHandler?(isDone)
        // Data에 관해서
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        // [X] TODO: deleteButton 처리
        deleteButtonTapHandler?()
    }
}

class TodoListHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var sectionTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
