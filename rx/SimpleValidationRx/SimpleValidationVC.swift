//
//  SimpleValidationVC.swift
//  rx
//
//  Created by 장혜성 on 2023/11/02.
//

import UIKit
import RxSwift
import RxCocoa


final class SimpleValidationVC : UIViewController {

    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidOutlet: UILabel!

    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidOutlet: UILabel!

    @IBOutlet weak var doSomethingOutlet: UIButton!

    let viewModel = SimpleValidationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameValidOutlet.text = "Username has to be at least \(viewModel.minimalUsernameLength) characters"
        passwordValidOutlet.text = "Password has to be at least \(viewModel.minimalPasswordLength) characters"
        
        let usernameValid = usernameOutlet.rx.text.orEmpty
            .map { $0.count >= self.viewModel.minimalUsernameLength }
            .share(replay: 1) // 이 맵이 없으면 각 바인딩에 대해 한 번 실행되며 rx는 기본적으로 상태 비저장입니다.

        let passwordValid = passwordOutlet.rx.text.orEmpty
            .map { $0.count >= self.viewModel.minimalPasswordLength }
            .share(replay: 1)

        let everythingValid = Observable.combineLatest(usernameValid, passwordValid) { $0 && $1 }
            .share(replay: 1)

        usernameValid
            .bind(to: passwordOutlet.rx.isEnabled)
            .disposed(by: viewModel.disposeBag)

        usernameValid
            .bind(to: usernameValidOutlet.rx.isHidden)
            .disposed(by: viewModel.disposeBag)

        passwordValid
            .bind(to: passwordValidOutlet.rx.isHidden)
            .disposed(by: viewModel.disposeBag)

        everythingValid
            .bind(to: doSomethingOutlet.rx.isEnabled)
            .disposed(by: viewModel.disposeBag)

        doSomethingOutlet.rx.tap
            .subscribe(onNext: { [weak self] _ in self?.showAlert() })
            .disposed(by: viewModel.disposeBag)
    }

    func showAlert() {
        let alert = UIAlertController(
            title: "RxExample",
            message: "This is wonderful",
            preferredStyle: .alert
        )
        let defaultAction = UIAlertAction(title: "Ok",
                                          style: .default,
                                          handler: nil)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
}
