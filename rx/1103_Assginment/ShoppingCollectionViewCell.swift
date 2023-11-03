//
//  ShoppingCollectionViewCell.swift
//  rx
//
//  Created by 장혜성 on 2023/11/03.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class ShoppingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ShoppingCollectionViewCell"
    
    let completeButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        return view
    }()
    
    let bookmarkButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "bookmark"), for: .normal)
        return view
    }()
    
    private let titleLabel = {
        let view = UILabel()
        view.textColor = .brown
        view.font = .systemFont(ofSize: 18)
        return view
    }()
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(row: ShoppingItem) {
        titleLabel.text = row.name
        let completeImage = row.isComplete ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "checkmark.square")
        completeButton.setImage(completeImage, for: .normal)
        
        let bookmarkImage = row.isBookmark ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
        bookmarkButton.setImage(bookmarkImage, for: .normal)
    }
    
    private func configureHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(completeButton)
        contentView.addSubview(bookmarkButton)
    }
    
    private func configureLayout() {
        
        completeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(8)
        }
        
        bookmarkButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(completeButton.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }
    }
    
}
