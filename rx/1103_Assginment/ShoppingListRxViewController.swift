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
    
    private var datas = ["a", "b", "c", "d", "e", "f", "g", "h", "j", "k", "l"]
    private lazy var items = BehaviorSubject(value: self.datas)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        bind()
    }
    
    private func bind() {
        
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
        view.addSubview(collectionView)
    }
    
    private func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
