//
//  AlbumExtensions.swift
//  BlueLibrarySwift
//
//  Created by MSH Labs on 1/3/17.
//  Copyright © 2017 Raywenderlich. All rights reserved.
//

import Foundation

extension Album {
  func ae_tableRepresentation() -> (titles:[String], values:[String]) {
    return (["Artist", "Album", "Genre", "Year"], [artist, title, genre, year])
  }
}
