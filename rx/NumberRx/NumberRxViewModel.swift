//
//  NumberRxViewModel.swift
//  rx
//
//  Created by 장혜성 on 2023/11/02.
//

import Foundation
import RxSwift

final class NumberRxViewModel {
    
    let subjectNumber01 = BehaviorSubject(value: 0)
    let subjectNumber02 = BehaviorSubject(value: 0)
    let subjectNumber03 = BehaviorSubject(value: 0)
    
    let disposeBag = DisposeBag()
}
