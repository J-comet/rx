//
//  DetailShoppingRxViewModel.swift
//  rx
//
//  Created by 장혜성 on 2023/11/03.
//

import Foundation

import RxSwift
import RxCocoa

final class DetailShoppingRxViewModel {

    let name = BehaviorSubject(value: "")
    var disposeBag = DisposeBag()
    
}
