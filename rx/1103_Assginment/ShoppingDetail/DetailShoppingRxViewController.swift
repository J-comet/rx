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
    
    var disposeBag = DisposeBag()
    
    let shoppingItemName = PublishSubject<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "상세 아이템"
        
        guard let shoppingItem else { return }
        configureHierarchy()
        configureLayout()
        
        bind()
        shoppingItemName.onNext(shoppingItem.name)
    }
    
    private func bind() {
        
        // TODO: 현재 textField 를 한번도 입력하지 않으면 수정 버튼을 눌렀을 때 데이터가 없다고 뜨는 중 원인 파악 필요
        shoppingItemName
            .bind(to: nameTextField.rx.text)
            .disposed(by: disposeBag)
        
        // 수정버튼 탭 했을 때 dismiss 및 클로저 전달
        editButton.rx
            .tap
            .withLatestFrom(nameTextField.rx.text.orEmpty)
            .subscribe(with: self) { owner, text in
                if text.isEmpty {
                    print("입력 데이터 없음")
                } else {
                    print("입력값 - ", text)
                    var updateItem = owner.shoppingItem
                    updateItem?.name = text
                    owner.completionHandler?(updateItem)
                    owner.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)
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

