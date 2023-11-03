//
//  SimplePickerViewRXVC.swift
//  rx
//
//  Created by 장혜성 on 2023/11/01.
//

import UIKit

import RxSwift
import RxCocoa

class SimplePickerViewRXVC: UIViewController {

    @IBOutlet var pickerView1: UIPickerView!
    @IBOutlet var pickerView2: UIPickerView!
    @IBOutlet var pickerView3: UIPickerView!
    
    let viewModel = SimplePickerRxViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.pickerItems
            .bind(to: pickerView1.rx.itemTitles) { _, item in
                return "\(item)"
            }
            .disposed(by: viewModel.disposeBag)

        pickerView1.rx.modelSelected(Int.self)
            .subscribe(onNext: { models in
                print("models selected 1: \(models)")
            })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.pickerItems
            .bind(to: pickerView2.rx.itemAttributedTitles) { _, item in
                return NSAttributedString(string: "\(item)",
                                          attributes: [
                                            NSAttributedString.Key.foregroundColor: UIColor.cyan,
                                            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.double.rawValue
                                        ])
            }
            .disposed(by: viewModel.disposeBag)

        pickerView2.rx.modelSelected(Int.self)
            .subscribe(onNext: { models in
                print("models selected 2: \(models)")
            })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.pickerColorItems
            .bind(to: pickerView3.rx.items) { _, item, _ in
                let view = UIView()
                view.backgroundColor = item
                return view
            }
            .disposed(by: viewModel.disposeBag)

        pickerView3.rx.modelSelected(UIColor.self)
            .subscribe(onNext: { models in
                print("models selected 3: \(models)")
            })
            .disposed(by: viewModel.disposeBag)
    }


}

