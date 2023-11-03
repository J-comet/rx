//
//  ShoppingCollectionViewCell.swift
//  rx
//
//  Created by 장혜성 on 2023/11/03.
//

import UIKit

import SnapKit

final class ShoppingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ShoppingCollectionViewCell"
    
    private let titleLabel = {
        let view = UILabel()
        view.textColor = .brown
        view.font = .systemFont(ofSize: 18)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(row: String) {
        titleLabel.text = row
    }
    
    private func configureHierarchy() {
        contentView.addSubview(titleLabel)
    }
    
    private func configureLayout() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
}
