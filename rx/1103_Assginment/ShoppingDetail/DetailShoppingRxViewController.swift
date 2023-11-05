//
//  DetailShoppingRxViewController.swift
//  rx
//
//  Created by 장혜성 on 2023/11/03.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class DetailShoppingRxViewController: UIViewController {
    
    var shoppingItem: ShoppingItem?
    var completionHandler: ((ShoppingItem?) -> Void)?
    
    let nameTextField = {
        let view = UITextField()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.backgroundColor = .lightGray
        view.font = .boldSystemFont(ofSize: 16)
        view.textAlignment = .center
        return view
    }()
    
    let editButton = {
        let view = UIButton()
        var attString = AttributedString("수정")
        attString.font = .systemFont(ofSize: 16, weight: .bold)
        var config = UIButton.Configuration.filled()
        config.attributedTitle = attString
        config.baseBackgroundColor = .link
        config.baseForegroundColor = .white
        view.configuration = config
        return view
    }()
    
    let viewModel = DetailShoppingRxViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "상세 아이템"
        
        configureHierarchy()
        configureLayout()
        bind()
        guard let shoppingItem else { return }
        viewModel.name.onNext(shoppingItem.name)
    }
    
    private func bind() {
        
        viewModel.name
            .bind(to: nameTextField.rx.text)
            .disposed(by: viewModel.disposeBag)
        
        nameTextField.rx
            .text
            .orEmpty
            .subscribe(with: self) { owner, text in
                owner.viewModel.name.onNext(text)
            }
            .disposed(by: viewModel.disposeBag)
        
        // 수정버튼 탭 했을 때 dismiss 및 클로저 전달
        editButton.rx
            .tap
            .withLatestFrom(viewModel.name)
            .subscribe(with: self) { owner, text in
                if text.isEmpty {
                    print("입력값 수정")
                } else {
                    var updateItem = owner.shoppingItem
                    updateItem?.name = text
                    owner.completionHandler?(updateItem)
                    owner.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: viewModel.disposeBag)
    }
    
    private func configureHierarchy() {
        view.addSubview(nameTextField)
        view.addSubview(editButton)
    }
    
    private func configureLayout() {
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(48)
            make.height.equalTo(44)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        
        editButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(nameTextField.snp.bottom).offset(48)
        }
    }
}

