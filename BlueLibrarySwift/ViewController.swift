/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class ViewController: UIViewController {

	@IBOutlet var dataTable: UITableView!
	@IBOutlet var toolbar: UIToolbar!
  @IBOutlet weak var scroller: HorizontalScroller!
  
  fileprivate var allAlbums = [Album]()
  fileprivate var currentAlbumData : (titles:[String], values:[String])?
  fileprivate var currentAlbumIndex = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//1
    self.navigationController?.navigationBar.isTranslucent = false
    currentAlbumIndex = 0
    
    //2
    allAlbums = LibraryAPI.sharedInstance.getAlbums()
    
    //3
    // the uitableview that presents the data
    dataTable.delegate = self
    dataTable.dataSource = self
    dataTable.backgroundView = nil
    view.addSubview(dataTable!)
    self.showDataForAlbum(currentAlbumIndex)
    
    loadPreviousState() //Memento
    scroller.delegate = self
    reloadScroller()
    
    NotificationCenter.default.addObserver(self, selector:#selector(ViewController.saveCurrentState), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
  
  func showDataForAlbum(_ albumIndex: Int) {
    // defensive code: make sure the requested index is lower than the amount of albums
    if (albumIndex < allAlbums.count && albumIndex > -1) {
      //fetch the album
      let album = allAlbums[albumIndex]
      //save the albums data to present if later in the tableview
      currentAlbumData = album.ae_tableRepresentation()
    } else {
      currentAlbumData = nil
    }
    // we have the data we need, let's refresh our tableview
    dataTable!.reloadData()
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let albumData = currentAlbumData {
      return albumData.titles.count
    } else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    if let albumData = currentAlbumData {
      cell.textLabel!.text = albumData.titles[indexPath.row]
      cell.detailTextLabel!.text = albumData.values[indexPath.row]
    }
    return cell
  }
  
  func reloadScroller() {
    allAlbums = LibraryAPI.sharedInstance.getAlbums()
    if currentAlbumIndex < 0 {
      currentAlbumIndex = 0
    } else if currentAlbumIndex >= allAlbums.count {
      currentAlbumIndex = allAlbums.count - 1
    }
    scroller.reload()
    showDataForAlbum(currentAlbumIndex)
  }
}

extension ViewController: UITableViewDelegate {
}

extension ViewController: HorizontalScrollerDelegate {
  func horizontalScrollerClickedViewAtIndex(_ scroller: HorizontalScroller, index: Int) {
    //1
    let previousAlbumView = scroller.viewAtIndex(currentAlbumIndex) as! AlbumView
    previousAlbumView.highlightAlbum(false)
    //2
    currentAlbumIndex = index
    //3 
    let albumView = scroller.viewAtIndex(index) as! AlbumView
    albumView.highlightAlbum(true)
    //4
    showDataForAlbum(index)
  }
  
  func numberOfViewsForHorizontalScroller(_ scroller: HorizontalScroller) -> (Int) {
    return allAlbums.count
  }
  
  func horizontalScrollerViewAtIndex(_ scroller: HorizontalScroller, index: Int) -> (UIView) {
    let album = allAlbums[index]
    let albumView = AlbumView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), albumCover: album.coverUrl)
    if currentAlbumIndex == index {
      albumView.highlightAlbum(true)
    } else {
      albumView.highlightAlbum(false)
    }
    return albumView
  }
  
  //MARK: Memento Pattern
  func saveCurrentState() {
    // When the user leaves the app and then comes back again, he wants it to be in the exact same state
    // he left it. In order to do this we need to save the currently displayed album.
    // Since it's only one piece of information we can use NSUserDefaults.
    UserDefaults.standard.set(currentAlbumIndex, forKey: "curretnAlbumIndex")
  }
  
  func loadPreviousState() {
    currentAlbumIndex = UserDefaults.standard.integer(forKey: "currentAlbumIndex")
    showDataForAlbum(currentAlbumIndex)
  }
  
  @objc func initialViewIndex(_ scroller: HorizontalScroller) -> Int {
    return currentAlbumIndex
  }
}











