//
//  SimplePickerRxViewModel.swift
//  rx
//
//  Created by 장혜성 on 2023/11/02.
//

import Foundation
import RxSwift
import UIKit

final class SimplePickerRxViewModel {
    
    let pickerItems = Observable.just([1, 2, 3])
    let pickerColorItems = Observable.just([UIColor.red, UIColor.green, UIColor.blue])
    
    let disposeBag = DisposeBag()
    
}
