//
//  NumberViewRxVC.swift
//  rx
//
//  Created by 장혜성 on 2023/11/02.
//

import UIKit

import RxSwift
import RxCocoa

final class NumberViewRxVC: UIViewController {
    
    @IBOutlet weak var number1: UITextField!
    @IBOutlet weak var number2: UITextField!
    @IBOutlet weak var number3: UITextField!

    @IBOutlet weak var result: UILabel!
    
    let viewModel = NumberRxViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.subjectNumber01
            .map { $0.description }
            .bind(to: number1.rx.text)
            .disposed(by: viewModel.disposeBag)

        viewModel.subjectNumber02
            .map { $0.description }
            .bind(to: number2.rx.text)
            .disposed(by: viewModel.disposeBag)
        
        viewModel.subjectNumber03
            .map { $0.description }
            .bind(to: number3.rx.text)
            .disposed(by: viewModel.disposeBag)
        
        number1
            .rx.text
            .orEmpty
            .map { Int($0) ?? 0 }
            .subscribe(with: self) { owner, value in
                owner.viewModel.subjectNumber01.onNext(value)
            }
            .disposed(by: viewModel.disposeBag)

        number2
            .rx.text
            .orEmpty
            .map { Int($0) ?? 0 }
            .subscribe(with: self) { owner, value in
                owner.viewModel.subjectNumber02.onNext(value)
            }
            .disposed(by: viewModel.disposeBag)
        
        number3
            .rx.text
            .orEmpty
            .map { Int($0) ?? 0 }
            .subscribe(with: self) { owner, value in
                owner.viewModel.subjectNumber03.onNext(value)
            }
            .disposed(by: viewModel.disposeBag)
        
        
        Observable.combineLatest(
            viewModel.subjectNumber01,
            viewModel.subjectNumber02,
            viewModel.subjectNumber03
        ) { textValue1, textValue2, textValue3 -> Int in
            return textValue1 + textValue2 + textValue3
        }
        .map { $0.description }
        .bind(to: result.rx.text)
        .disposed(by: viewModel.disposeBag)
    }
}
