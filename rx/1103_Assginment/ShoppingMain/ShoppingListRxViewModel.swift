//
//  ShoppingListRxViewModel.swift
//  rx
//
//  Created by 장혜성 on 2023/11/03.
//

import Foundation

import RxSwift
import RxCocoa

final class ShoppingListRxViewModel {
    var datas = [ShoppingItem]()
    lazy var shoppingItems = BehaviorSubject(value: self.datas)
    
    let disposeBag = DisposeBag()
}
