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
    
    lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout())
        view.register(ShoppingCollectionViewCell.self, forCellWithReuseIdentifier: ShoppingCollectionViewCell.identifier)
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
            .bind(to: collectionView.rx.items(cellIdentifier: ShoppingCollectionViewCell.identifier, cellType: ShoppingCollectionViewCell.self)) { (row, element, cell) in
                
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
        
        // collectionView - didSelectItemAt 과 같은 역할을 하기 위해서는 modelSelected + itemSelected 를 같이 사용해야됨.
        Observable.zip(collectionView.rx.itemSelected, collectionView.rx.modelSelected(ShoppingItem.self))
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
        
        // 스크롤시 소프트키보드 hide
        collectionView.rx
            .contentOffset
            .subscribe(with: self) { owner, _ in
                owner.addTextField.resignFirstResponder()
            }
            .disposed(by: disposeBag)
        
        
        //        // cell 의 데이터가 필요할 때
        //        collectionView.rx
        //            .modelSelected(String.self)
        //            .subscribe(with: self, onNext: { owner, value in
        //                print("modelSelected - ", value)
        //            })
        //            .disposed(by: disposeBag)
        //
        //        // cell 의 indexPath 가 필요할 때
        //        collectionView.rx
        //            .itemSelected
        //            .subscribe(with: self) { owner, indexPath in
        //                print("itemSelected", indexPath)
        //            }
        //            .disposed(by: disposeBag)
    }
    
    private func configureHierarchy() {
        view.addSubview(addTextField)
        view.addSubview(addButton)
        view.addSubview(collectionView)
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
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension ShoppingListRxViewController {
    
    func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 8
        let count: CGFloat = 1
        let width: CGFloat = UIScreen.main.bounds.width - (spacing * (count + 1)) // 디바이스 너비 계산
        
        layout.itemSize = CGSize(width: width / count, height: 60)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)  // 컨텐츠가 잘리지 않고 자연스럽게 표시되도록 여백설정
        layout.minimumLineSpacing = spacing         // 셀과셀 위 아래 최소 간격
        layout.minimumInteritemSpacing = spacing    // 셀과셀 좌 우 최소 간격
        return layout
    }
    
}
