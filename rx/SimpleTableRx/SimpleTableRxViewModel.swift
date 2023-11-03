//
//  SimpleTableRxViewModel.swift
//  rx
//
//  Created by 장혜성 on 2023/11/02.
//

import Foundation
import RxSwift

final class SimpleTableRxViewModel {
    
    let items = Observable.just(
        (0..<20).map { "\($0)" }
    )
    
    let disposeBag = DisposeBag()
    
}
