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

struct SelectShoppingItem {
    let index: Int
    let Item: String
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
    
    private var datas = [String]()
    private lazy var items = BehaviorSubject(value: self.datas)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        configureHierarchy()
        configureLayout()
        collectionViewBind()
        addButtonBind()
    }
    
    private func addButtonBind() {
        
        addButton.rx
            .tap
            .withLatestFrom(addTextField.rx.text.orEmpty)
            .subscribe(with: self) { owner, text in
                if !text.isEmpty {
                    print(text, "입력됨")
                    owner.datas.insert(text, at: 0)
                    owner.items.onNext(owner.datas)
                    owner.addTextField.resignFirstResponder()
                    owner.addTextField.text = nil
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func collectionViewBind() {
        
        items
            .bind(to: collectionView.rx.items(cellIdentifier: ShoppingCollectionViewCell.identifier, cellType: ShoppingCollectionViewCell.self)) { (row, element, cell) in
                cell.configureCell(row: element)
            }
            .disposed(by: disposeBag)
        
        // collectionView - didSelectItemAt 과 같은 역할을 하기 위해서는 modelSelected + itemSelected 를 같이 사용해야됨.
        Observable.zip(collectionView.rx.itemSelected, collectionView.rx.modelSelected(String.self))
//            .map { "셀 선택 \($0), \($1)" }
            .map { SelectShoppingItem(index: $0.item, Item: $1) }
            .subscribe(with: self) { owner, selectedItem in
                print(selectedItem)
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
        
        layout.itemSize = CGSize(width: width / count, height: 70)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)  // 컨텐츠가 잘리지 않고 자연스럽게 표시되도록 여백설정
        layout.minimumLineSpacing = spacing         // 셀과셀 위 아래 최소 간격
        layout.minimumInteritemSpacing = spacing    // 셀과셀 좌 우 최소 간격
        return layout
    }
    
}
