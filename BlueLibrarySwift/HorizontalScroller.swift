//
//  HorizontalScroller.swift
//  BlueLibrarySwift
//
//  Created by MSH Labs on 1/3/17.
//  Copyright © 2017 Raywenderlich. All rights reserved.
//

import UIKit

@objc protocol HorizontalScrollerDelegate {
  // ask the delegate how many views he wants to present inside the horizontal scroller
  func numberOfViewsForHorizontalScroller(_ scroller: HorizontalScroller) -> Int
  // ask the delegate to return the view that should appear at <index>
  func horizontalScrollerViewAtIndex(_ scroller: HorizontalScroller, index:Int) -> UIView
  // inform the delegate what the view at <index> has been clicked
  func horizontalScrollerClickedViewAtIndex(_ scroller: HorizontalScroller, index:Int)
  // ask the delegate for the index of the initial view to display. this method is optional
  // and defaults to 0 if it's not implemented by the delegate
  @objc optional func initialViewIndex(_ scroller: HorizontalScroller) -> Int
}

class HorizontalScroller: UIView {

  weak var delegate: HorizontalScrollerDelegate?
  
  //1
  fileprivate let VIEW_PADDING = 10
  fileprivate let VIEW_DIMENSIONS = 100
  fileprivate let VIEWS_OFFSET = 100
  
  //2
  fileprivate var scroller : UIScrollView!
  //3
  var viewArray = [UIView]()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeScrollView()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeScrollView()
  }
  
  func initializeScrollView() {
    //1
    scroller = UIScrollView()
    scroller.delegate = self
    addSubview(scroller)
    
    //2
    scroller.translatesAutoresizingMaskIntoConstraints = false
    //3
    self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
    self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
    self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
    self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))

    
    //4
    let tapRecognizer = UITapGestureRecognizer(target: self, action:#selector(HorizontalScroller.scrollerTapped(_:)))
    scroller.addGestureRecognizer(tapRecognizer)
  }
  
  func scrollerTapped(_ gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: gesture.view)
    if let delegate = delegate {
      for index in 0..<delegate.numberOfViewsForHorizontalScroller(self) {
        let view = scroller.subviews[index]
        if view.frame.contains(location) {
          delegate.horizontalScrollerClickedViewAtIndex(self, index: index)
          scroller.setContentOffset(CGPoint(x: view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, y: 0), animated:true)
          break
        }
      }
    }
  }
  
  func viewAtIndex(_ index :Int) -> UIView {
    return viewArray[index]
  }
  
  func reload() {
    // 1 - Check if there is a delegate, if not there is nothing to load.
    if let delegate = delegate {
      //2 - Will keep adding new album views on reload, need to reset.
      viewArray = []
      let views: NSArray = scroller.subviews as NSArray
      
      // 3 - remove all subviews
      for view in views {
        (view as AnyObject).removeFromSuperview()
      }
      
      // 4 - xValue is the starting point of the views inside the scroller
      var xValue = VIEWS_OFFSET
      for index in 0..<delegate.numberOfViewsForHorizontalScroller(self) {
        // 5 - add a view at the right position
        xValue += VIEW_PADDING
        let view = delegate.horizontalScrollerViewAtIndex(self, index: index)
        view.frame = CGRectMake(CGFloat(xValue), CGFloat(VIEW_PADDING), CGFloat(VIEW_DIMENSIONS), CGFloat(VIEW_DIMENSIONS))
        scroller.addSubview(view)
        xValue += VIEW_DIMENSIONS + VIEW_PADDING
        // 6 - Store the view so we can reference it later
        viewArray.append(view)
      }
      // 7
      scroller.contentSize = CGSize(width: CGFloat(xValue + VIEWS_OFFSET), height: frame.size.height)
      
      // 8 - If an initial view is defined, center the scroller on it
      if let initialView = delegate.initialViewIndex?(self) {
        scroller.setContentOffset(CGPoint(x: CGFloat(initialView)*CGFloat((VIEW_DIMENSIONS + (2 * VIEW_PADDING))), y: 0), animated: true)
      }
    }
  }
  
  func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
    return CGRect(x: x, y: y, width: width, height: height)
  }
  
  override func didMoveToSuperview() {
    reload()
  }
  
  func centerCurrentView() {
    var xFinal = Int(scroller.contentOffset.x) + (VIEWS_OFFSET/2) + VIEW_PADDING
    let viewIndex = xFinal / (VIEW_DIMENSIONS + (2*VIEW_PADDING))
    xFinal = viewIndex * (VIEW_DIMENSIONS + (2*VIEW_PADDING))
    scroller.setContentOffset(CGPoint(x: xFinal, y: 0), animated: true)
    if let delegate = delegate {
      delegate.horizontalScrollerClickedViewAtIndex(self, index: Int(viewIndex))
    }
  }
}

extension HorizontalScroller: UIScrollViewDelegate {
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      centerCurrentView()
    }
  }
  
  func scrollViewDidEndDeceleratong(_ scrollView: UIScrollView) {
    centerCurrentView()
  }
  
}






























