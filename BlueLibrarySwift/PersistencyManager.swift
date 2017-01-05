//
//  PersistencyManager.swift
//  BlueLibrarySwift
//
//  Created by MSH Labs on 1/3/17.
//  Copyright © 2017 Raywenderlich. All rights reserved.
//

import UIKit

class PersistencyManager: NSObject {
  
  fileprivate var albums = [Album]()
  
  override init() {
    let album1 = Album(title: "Best of Bowie",
                       artist: "David Bowie",
                       genre: "Pop",
                       coverUrl: "https://s3.amazonaws.com/CoverProject/album/album_david_bowie_best_of_bowie.png",
                       year: "1992")

    let album2 = Album(title: "It's My Life",
                       artist: "No Doubt",
                       genre: "Pop",
                       coverUrl: "https://s3.amazonaws.com/CoverProject/album/album_no_doubt_its_my_life_bathwater.png",
                       year: "2003")
    
    let album3 = Album(title: "Nothing Like The Sun",
                       artist: "Sting",
                       genre: "Pop",
                       coverUrl: "https://s3.amazonaws.com/CoverProject/album/album_sting_nothing_like_the_sun.png",
                       year: "1999")
    
    let album4 = Album(title: "Staring at the Sun",
                       artist: "U2",
                       genre: "Pop",
                       coverUrl: "https://s3.amazonaws.com/CoverProject/album/album_u2_staring_at_the_sun.png",
                       year: "2000")
    
    let album5 = Album(title: "American Pie",
                       artist: "Madonna",
                       genre: "Pop",
                       coverUrl: "https://s3.amazonaws.com/CoverProject/album/album_madonna_american_pie.png",
                       year: "2000")
    
    albums = [album1, album2, album3, album4, album5]
  }
  
  func getAlbums() -> [Album] {
    return albums
  }
  
  func addAlbum(_ album: Album, index: Int) {
    if (albums.count >= index) {
      albums.insert(album, at: index)
    } else {
      albums.append(album)
    }
  }
  
  func deleteAlbumAtIndex(_ index: Int) {
    albums.remove(at: index)
  }
  
  func saveImage(_ image: UIImage, filename: String) {
    let path = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("/Documents/\(filename)")
    let data = UIImagePNGRepresentation(image)
    do {
      try data!.write(to: path)
    } catch let error {
      print(error)
    }
  }
  
  func getImage(_ filename: String) -> UIImage? {
    let path = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("/Documents/\(filename)")
    do{
      let data = try Data(contentsOf: path)
    
      
      return UIImage(data: data as Data)
    }catch{
      return nil
    }
  }
  
}
