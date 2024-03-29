//
//  StringExtension.swift
//  MyTasks
//
//  Created by Игорь Бопп on 02.12.2019.
//  Copyright © 2019 igor.bopp. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)

        return boundingBox.height
    }
}
