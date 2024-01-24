//
//  UIView+Extension.swift
//  JioMeetVideoeKYCSample
//
//  Created by Rohit41.Kumar on 24/01/24.
//

import Foundation
import UIKit

extension UIView {
	func pinViewToSuperView(superView: UIView) {
		NSLayoutConstraint.activate([
			leadingAnchor.constraint(equalTo: superView.leadingAnchor),
			trailingAnchor.constraint(equalTo: superView.trailingAnchor),
			topAnchor.constraint(equalTo: superView.topAnchor),
			bottomAnchor.constraint(equalTo: superView.bottomAnchor),
		])
	}
}
