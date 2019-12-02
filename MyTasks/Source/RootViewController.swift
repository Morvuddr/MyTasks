//
//  RootView.swift
//  MyTasks
//
//  Created by Игорь Бопп on 01.12.2019.
//  Copyright © 2019 igor.bopp. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private var childView: UIViewController

    init(childVC: UIViewController) {
        self.childView = childVC
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addChild(childView)
        self.view.addSubview(childView.view)
        childView.view.bounds = self.view.bounds
        childView.didMove(toParent: self)

    }


}
