//
//  ShoppingListRxView.swift
//  rx
//
//  Created by 장혜성 on 2023/11/03.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

struct ShoppingItem {
    let idx = UUID().uuidString
    var name: String
    var isComplete = false
    var isBookmark = false
}

final class ShoppingListRxViewController: UIViewController {
    
    private let tableView: UITableView = {
        let view = UITableView()
        view.register(ShoppingTableViewCell.self, forCellReuseIdentifier: ShoppingTableViewCell.identifier)
        view.backgroundColor = .white
        view.rowHeight = 60
        view.separatorStyle = .none
        return view
    }()
    
    let addTextField = {
        let view = UITextField()
        view.placeholder = "추가할 아이템을 입력해보세요"
        return view
    }()
    
    let addButton = {
        let view = UIButton()
        var attString = AttributedString("추가")
        attString.font = .systemFont(ofSize: 14, weight: .medium)
        var config = UIButton.Configuration.filled()
        config.attributedTitle = attString
        config.contentInsets = .init(top: 8, leading: 20, bottom: 8, trailing: 20)
        config.baseBackgroundColor = .lightGray
        config.baseForegroundColor = .black
        view.configuration = config
        return view
    }()
    
    private var datas = [ShoppingItem]()
    private lazy var shoppingItems = BehaviorSubject(value: self.datas)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "쇼핑 목록"
        
        configureHierarchy()
        configureLayout()
        collectionViewBind()
        addButtonBind()
    }
    
    private func addButtonBind() {
        
        addButton.rx
            .tap
            .withLatestFrom(addTextField.rx.text.orEmpty)
            .subscribe(with: self) { owner, inputText in
                if !inputText.isEmpty {
                    print(inputText, "입력됨")
                    let item = ShoppingItem(name: inputText)
                    owner.datas.insert(item, at: 0)
                    owner.shoppingItems.onNext(owner.datas)
                    owner.addTextField.resignFirstResponder()
                    owner.addTextField.text = nil
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func collectionViewBind() {
        
        shoppingItems
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.identifier, cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
                
                // 완료 기능
                cell.completeButton.rx
                    .tap
                    .subscribe(with: self) { owner, _ in
                        var updateItem = owner.datas[row]
                        updateItem.isComplete = !updateItem.isComplete
                        owner.datas.enumerated().forEach { index, item in
                            if item.idx == updateItem.idx {
                                owner.datas[index] = updateItem
                            }
                        }
                        owner.shoppingItems.onNext(owner.datas)
                    }
                    .disposed(by: cell.disposeBag)  // cell 의 다운로드 버튼이기에 cell의 disposeBag 을 사용
                
                // 북마크 기능
                cell.bookmarkButton.rx
                    .tap
                    .subscribe(with: self) { owner, _ in
                        var updateItem = owner.datas[row]
                        updateItem.isBookmark = !updateItem.isBookmark
                        owner.datas.enumerated().forEach { index, item in
                            if item.idx == updateItem.idx {
                                owner.datas[index] = updateItem
                            }
                        }
                        owner.shoppingItems.onNext(owner.datas)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.configureCell(row: element)
            }
            .disposed(by: disposeBag)
        
        // didSelectItemAt 과 같은 역할을 하기 위해서는 modelSelected + itemSelected 를 같이 사용해야됨.
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(ShoppingItem.self))
            .subscribe(with: self) { owner, selectedItem in
                // 상세페이지로 이동해서 수정기능 만들기
                let vc = DetailShoppingRxViewController()
                vc.shoppingItem = selectedItem.1
                
                vc.completionHandler = { [weak self] updateItem in
                    guard let updateItem, let self else { return }
                    self.datas.enumerated().forEach { index, item in
                        if updateItem.idx == item.idx {
                            print(updateItem)
                            self.datas[index] = updateItem
                        }
                    }
                    self.shoppingItems.onNext(self.datas)
                }
                
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        tableView.rx
            .itemDeleted
            .subscribe(with: self) { owner, indexPath in
                owner.datas.remove(at: indexPath.row)
                owner.shoppingItems.onNext(owner.datas)
            }
            .disposed(by: disposeBag)
        
        // 스크롤시 소프트키보드 hide
        tableView.rx
            .contentOffset
            .subscribe(with: self) { owner, _ in
                owner.addTextField.resignFirstResponder()
            }
            .disposed(by: disposeBag)

    }
    
    private func configureHierarchy() {
        view.addSubview(addTextField)
        view.addSubview(addButton)
        view.addSubview(tableView)
        
    }
    
    private func configureLayout() {
        
        addTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(50)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(addTextField)
            make.trailing.equalToSuperview().inset(16)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
