//
//  Created by Dmitry Frishbuter on 28/01/2019
//  Copyright © 2019 Dmitry Frishbuter. All rights reserved.
//

import UIKit
import DynamicButton

final class ViewController: UIViewController {

    private lazy var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.cornerRadius = 10
        return view
    }()

    private lazy var dynamicButton: DynamicButton = {
        let button = DynamicButton()
        button.setBackgroundColor(.white, for: .normal)
        button.setBorderColor(.red, for: .normal)
        button.setShadowOpacity(0.6, for: .normal)
        button.setShadowRadius(3.0, for: .normal)
        button.setImage(UIImage(named: "icFacebook"), for: .normal)
//        button.setShadowOpacity(1.0, for: .normal)
//        button.setBackgroundColor(.blue, for: .highlighted)
        button.cornerRadius = 10
        button.addTarget(self, action: #selector(dynamicButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var systemButton: UIButton = {
        let button = UIButton(type: .system)
//        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.setBackgroundImage(UIImage.colored(.red)?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setBackgroundImage(UIImage.colored(.blue)?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        button.addTarget(self, action: #selector(systemButtonPressed), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(dynamicButton)
        view.addSubview(systemButton)
        view.addSubview(mainView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dynamicButton.frame = CGRect(x: 16, y: 200, width: view.bounds.width - 32, height: 40)
        systemButton.frame = CGRect(x: 16, y: dynamicButton.frame.maxY + 16, width: view.bounds.width - 32, height: 40)
        mainView.frame = CGRect(x: 16, y: systemButton.frame.maxY + 16, width: view.bounds.width - 32, height: 80)
    }

    @objc private func dynamicButtonPressed() {
        print("\(self) \(#function)")
    }

    @objc private func systemButtonPressed() {
        print("\(self) \(#function)")
    }
}
