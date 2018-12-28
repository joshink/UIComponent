//
//  CollectionReuseViewManager.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-21.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public protocol CollectionViewReusableView: class {
  func prepareForReuse()
}

public class CollectionReuseViewManager: NSObject {

  public static let shared = CollectionReuseViewManager()

  /// Time it takes for CollectionReuseViewManager to
  /// dump all reusableViews to save memory
  public var lifeSpan: TimeInterval = 5.0

  /// When `removeFromCollectionViewWhenReuse` is enabled,
  /// cells will always be removed from Collection View during reuse.
  /// This is slower but it doesn't influence the `isHidden` property
  /// of individual cells.
  public var removeFromCollectionViewWhenReuse = false

  var reusableViews: [String: [UIView]] = [:]
  var cleanupTimer: Timer?

  public func queue(identifier id: String? = nil,
                    view: UIView) {
    let identifier = id ?? NSStringFromClass(type(of: view))
    view.reuseManager = nil
    if removeFromCollectionViewWhenReuse {
      view.removeFromSuperview()
    } else {
      view.isHidden = true
    }
    if reusableViews[identifier] != nil && !reusableViews[identifier]!.contains(view) {
      reusableViews[identifier]?.append(view)
    } else {
      reusableViews[identifier] = [view]
    }
    if let cleanupTimer = cleanupTimer {
      cleanupTimer.fireDate = Date().addingTimeInterval(lifeSpan)
    } else {
      cleanupTimer = Timer.scheduledTimer(timeInterval: lifeSpan, target: self,
                                          selector: #selector(cleanup), userInfo: nil, repeats: false)
    }
  }

  public func dequeue<T: UIView> (identifier: String = NSStringFromClass(T.self),
                                  _ defaultView: @autoclosure () -> T) -> T {
    let queuedView = reusableViews[identifier]?.popLast() as? T
    let view = queuedView ?? defaultView()
    if let view = view as? CollectionViewReusableView {
      view.prepareForReuse()
    }
    if !removeFromCollectionViewWhenReuse {
      view.isHidden = false
    }
    view.reuseManager = self
    return view
  }

  public func dequeue<T: UIView> (identifier: String = NSStringFromClass(T.self),
                                  type: T.Type) -> T {
    return dequeue(identifier: identifier, type.init())
  }

  @objc func cleanup() {
    for views in reusableViews.values {
      for view in views {
        view.removeFromSuperview()
      }
    }
    reusableViews.removeAll()
    cleanupTimer?.invalidate()
    cleanupTimer = nil
  }
}
