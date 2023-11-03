//
//  SimpleTableRxVC.swift
//  rx
//
//  Created by 장혜성 on 2023/11/01.
//

import UIKit
import RxSwift
import RxCocoa

class SimpleTableRXVC: UIViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    let viewModel = SimpleTableRxViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.items
            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element) @ row \(row)"
            }
            .disposed(by: viewModel.disposeBag)

        tableView.rx
            .modelSelected(String.self)
            .subscribe(onNext:  { value in
                print(value)
            })
            .disposed(by: viewModel.disposeBag)

        tableView.rx
            .itemAccessoryButtonTapped
            .subscribe(onNext: { indexPath in
                print("Tapped Detail @ \(indexPath.section),\(indexPath.row)")
            })
            .disposed(by: viewModel.disposeBag)

    }

}
