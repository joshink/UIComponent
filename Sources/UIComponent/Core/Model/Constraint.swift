//  Created by Luke Zhao on 8/22/20.

import UIKit
import BaseToolbox

public struct Constraint {
  public var minSize: CGSize
  public var maxSize: CGSize

  public init(
    minSize: CGSize = -.infinity,
    maxSize: CGSize = .infinity
  ) {
    self.minSize = minSize
    self.maxSize = maxSize
  }

  public static func tight(_ size: CGSize) -> Constraint {
    Constraint(minSize: size, maxSize: size)
  }

  public func inset(by insets: UIEdgeInsets) -> Constraint {
    Constraint(
      minSize: CGSize(
        width: max(0, minSize.width == .infinity ? .infinity : minSize.width - insets.left - insets.right),
        height: max(0, minSize.height == .infinity ? .infinity : minSize.height - insets.top - insets.bottom)
      ),
      maxSize: CGSize(
        width: max(0, maxSize.width == .infinity ? .infinity : maxSize.width - insets.left - insets.right),
        height: max(0, maxSize.height == .infinity ? .infinity : maxSize.height - insets.top - insets.bottom)
      )
    )
  }
}

extension CGSize {
  public func bound(to constraint: Constraint) -> CGSize {
    CGSize(
      width: width.clamp(constraint.minSize.width, constraint.maxSize.width),
      height: height.clamp(constraint.minSize.height, constraint.maxSize.height)
    )
  }
}
