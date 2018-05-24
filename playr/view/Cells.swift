//
//  Cells.swift
//  playr
//
//  Created by Michel Balamou on 5/21/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation


//----------------------------------------------------------------------
// VIEWED ROW
//----------------------------------------------------------------------

class ViewedRow: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    var net: NetworkModel!
    
    @IBOutlet weak var collectionCell: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return net.viewed.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ViewedCell", for: indexPath) as! ViewedCell
        
        // SHOW VIEWED MOVIES/SHOWS
        cell.film = net.viewed[indexPath.row]
        cell.play = net.play
        cell.displayInfo = net.displayInfo
        cell.setup()
        
        return cell
    }
    
    
    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    {
        let itemsPerRow: CGFloat = 4
        let hardCodedPadding: CGFloat = 5
        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}


//----------------------------------------------------------------------
// CATEGORY ROW
//----------------------------------------------------------------------
class CategoryRow: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate
{
    var rowType = "Movie"
    var net: NetworkModel!
    
    @IBOutlet weak var collectionCell: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        switch (rowType)
        {
            case "Movie":
                return net.movies.count
            case "Series":
                return net.series.count
            default:
                return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        //SHOW MOVIES/SERIES
        switch (rowType)
        {
        case "Movie":
            if let URL = net.movies[indexPath.row].poster {
                cell.moviePoster.loadCache(link: URL, contentMode: .scaleAspectFill)
            }
            break
        case "Series":
            if let URL = net.series[indexPath.row].poster {
                cell.moviePoster.loadCache(link: URL, contentMode: .scaleAspectFill)
            }
            break
        default:
            break
        }
        
        return cell
    }
    
    
    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    {
        let itemsPerRow: CGFloat = 4
        let hardCodedPadding: CGFloat = 5
        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
}

//----------------------------------------------------------------------
// VIEWED CELL
//----------------------------------------------------------------------

class ViewedCell: UICollectionViewCell {
    
    @IBOutlet weak var sub: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var stoppedAtView: UIView!
    @IBOutlet weak var duration: UIView!
    
    var play: (Viewed) -> () = {_ in}
    var displayInfo: (Viewed) -> () = {_ in}
    var film: Viewed!
    
    func setup(){
        
        self.configureTime(duration: film.duration, stoppedAt: film.stoppedAt ?? 1) // set the red bar below the viewed movie
        self.sub.text = film.label() // set Label
        
        if let poster = film.poster {
            posterView.loadCache(link: poster, contentMode: UIViewContentMode.scaleAspectFit) // load poster asynchronously
        }
        
        if let episode = film as? Episode,
            let series = episode.mainSeries,
            let poster = series.poster
        {
             posterView.loadCache(link: poster, contentMode: UIViewContentMode.scaleAspectFit)
        }
    }
    
    // Set view width
    func configureTime(duration: Int, stoppedAt: Int)
    {
        let newWidth = self.duration.frame.width * CGFloat(Float(stoppedAt)/Float(duration))
        self.stoppedAtView.frame = CGRect(0, 0, newWidth, self.stoppedAtView.frame.height)
    }
    
    // When clicking on play movie -> execute closure
    @IBAction func play(_ sender: UIButton)
    {
        self.play(film)
    }
    
    // When clicking on display info -> execute closure
    @IBAction func openInfo(_ sender: UIButton)
    {
        self.displayInfo(film)
    }
}

//----------------------------------------------------------------------
// MOVIE CELL
//----------------------------------------------------------------------

class MovieCell: UICollectionViewCell {
    @IBOutlet weak var moviePoster: UIImageView!
}



