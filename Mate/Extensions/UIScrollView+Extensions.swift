//
//  UIScrollView+Extensions.swift
//  Mate
//
//  Created by Vladimirus on 25.12.2021.
//

import UIKit

extension UIScrollView {
   func scrollToRight(animated: Bool) {
     if self.contentSize.width < self.bounds.size.width { return }
       let rightOffset = CGPoint(x: (self.contentSize.width - self.bounds.size.width) + contentInset.right, y: 0)
     self.setContentOffset(rightOffset, animated: animated)
  }
}
