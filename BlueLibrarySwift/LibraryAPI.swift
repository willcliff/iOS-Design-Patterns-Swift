//
//  LibraryAPI.swift
//  BlueLibrarySwift
//
//  Created by MSH Labs on 1/3/17.
//  Copyright © 2017 Raywenderlich. All rights reserved.
//

import UIKit

class LibraryAPI: NSObject {
  fileprivate let persistencyManager: PersistencyManager
  fileprivate let httpClient: HTTPClient
  fileprivate let isOnline: Bool
  
  //1
  class var sharedInstance: LibraryAPI {
    //2
    struct Singleton {
      //3
      static let instance = LibraryAPI()
    }
    //4
    return Singleton.instance
  }
  
  override init() {
    persistencyManager = PersistencyManager()
    httpClient = HTTPClient()
    isOnline = false
    
    super.init()
    NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImage), name: NSNotification.Name("BLDownloadImageNotification"), object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func downloadImage(notification: Notification) {
    //1
    let userInfo = notification.userInfo as! [String: AnyObject]
    let imageView = userInfo["imageView"] as! UIImageView?
    let coverUrl = userInfo["coverUrl"] as! String
    
    //2
    if let imageViewUnWrapped = imageView {
      imageViewUnWrapped.image = persistencyManager.getImage((NSURL(string: coverUrl)?.lastPathComponent)!)
      if imageViewUnWrapped.image == nil {
        //3
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
          let downloadedImage = self.httpClient.downloadImage(coverUrl as String)
          //4
          DispatchQueue.main.sync(execute: { () -> Void in
            imageViewUnWrapped.image = downloadedImage
            self.persistencyManager.saveImage(downloadedImage, filename: (NSURL(string: coverUrl)?.lastPathComponent)!)
          })
        })
      }
    }
  }
  
  func getAlbums() -> [Album] {
    return persistencyManager.getAlbums()
  }
  
  func addAlbum(album: Album, index: Int) {
    persistencyManager.addAlbum(album, index: index)
    if isOnline {
      httpClient.postRequest("/api/addAlbum", body: album.description)
    }
  }
  
  func deleteAlbum(index: Int) {
    persistencyManager.deleteAlbumAtIndex(index)
    if isOnline {
      httpClient.postRequest("/api/deleteAlbum", body: "\(index)")
    }
  }
  
}
