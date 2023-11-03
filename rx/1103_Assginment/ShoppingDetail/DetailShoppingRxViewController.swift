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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "상세 아이템"
        
        configureHierarchy()
        configureLayout()
        
        guard let shoppingItem else { return }
        nameTextField.text = shoppingItem.name
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
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
    }
}

