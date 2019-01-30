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

    private lazy var horizontalButton: DynamicButton = {
        let button = DynamicButton()
        button.setBackgroundColor(.white, for: .normal)
        button.setBorderColor(.red, for: .normal)
        button.setShadowOpacity(0.6, for: .normal)
        button.setImage(UIImage(named: "icFacebook"), for: .normal)
        button.cornerRadius = 10
        button.addTarget(self, action: #selector(dynamicButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var verticalButton: DynamicButton = {
        let button = DynamicButton()
        button.imageAlignment = .end
        button.layoutDirection = .horizontal
        button.layoutVerticalAlignment = .bottom
        button.layoutHorizontalAlignment = .right
        button.setBackgroundColor(.white, for: .normal)
        button.setBorderColor(.red, for: .normal)
        button.setShadowOpacity(0.6, for: .normal)
        button.setImage(UIImage(named: "icFacebook"), for: .normal)
        button.cornerRadius = 10
        button.addTarget(self, action: #selector(dynamicButtonPressed), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(horizontalButton)
        view.addSubview(verticalButton)
//        view.addSubview(mainView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        horizontalButton.frame = CGRect(x: 16, y: 200, width: view.bounds.width - 32, height: 40)
        verticalButton.frame = CGRect(x: 16, y: horizontalButton.frame.maxY + 16, width: view.bounds.width / 2, height: view.bounds.width / 2)
//        mainView.frame = CGRect(x: 16, y: systemButton.frame.maxY + 16, width: view.bounds.width - 32, height: 80)
    }

    @objc private func dynamicButtonPressed() {
//        print("\(self) \(#function)")
    }

    @objc private func systemButtonPressed() {
//        print("\(self) \(#function)")
    }
}
