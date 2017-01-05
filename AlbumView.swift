//
//  AlbumView.swift
//  BlueLibrarySwift
//
//  Created by MSH Labs on 1/3/17.
//  Copyright © 2017 Raywenderlich. All rights reserved.
//

import UIKit

class AlbumView: UIView {
  
  fileprivate var coverImage: UIImageView!
  fileprivate var indicator: UIActivityIndicatorView!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  init(frame: CGRect, albumCover: String) {
    super.init(frame: frame)
    commonInit()
    NotificationCenter.default.post(name: NSNotification.Name("BLDownloadImageNotification"), object: self, userInfo: ["imageView":coverImage, "coverUrl" : albumCover])

  }
  
  deinit {
    coverImage.removeObserver(self, forKeyPath: "image")
  }
  
  func commonInit() {
    backgroundColor = UIColor.black
    coverImage = UIImageView(frame: CGRect(x: 5, y: 5, width: frame.size.width - 10, height: frame.size.height - 10))
    addSubview(coverImage)
    coverImage.addObserver(self, forKeyPath: "image", options: [], context: nil)
    
    indicator = UIActivityIndicatorView()
    indicator.center = center
    indicator.activityIndicatorViewStyle = .whiteLarge
    indicator.startAnimating()
    addSubview(indicator)
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "image" {
      indicator.stopAnimating()
    }
  }

  func highlightAlbum(_ didHighlightView: Bool) {
    if didHighlightView == true {
      backgroundColor = UIColor.white
    } else {
      backgroundColor = UIColor.black
    }
  }
  
  func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
    return CGRect(x: x, y: y, width: width, height: height)
  }
  
  
  
  

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
