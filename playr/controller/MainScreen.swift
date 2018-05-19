//
//  MainScreen.swift
//  playr
//
//  Created by Michel Balamou on 5/18/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation
import UIKit

class MainScreen: UIViewController
{
    var callableIndicator = Viewed() // For network use only
    var callableMovies = Movie() // For network use only
    
    var viewedMovies: [Viewed] = []
    var movieList: [Movie] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    //----------------------------------------------------------------------
    // METHODS
    //----------------------------------------------------------------------
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        loadViewed()
        loadMovies()
    }
    
    // STOP ROTATION ANIMATION
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        coordinator.animate(alongsideTransition: nil) { (_) in
            UIView.setAnimationsEnabled(true)
        }
        UIView.setAnimationsEnabled(false)
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    //----------------------------------------------------------------------
    // FETCHING DATA
    //----------------------------------------------------------------------
    func loadViewed()
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        callableIndicator.load(userid: 1)
        {
            results, errorMessage in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let openResults = results as? [Viewed] {
                self.viewedMovies = openResults
                
                print(self.viewedMovies)
                self.collectionView.reloadData()
            }
            if !errorMessage.isEmpty { print("Search error loading viewed: " + errorMessage) }
        }
    }
    
    func loadMovies()
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        callableMovies.load()
        {
            results, errorMessage in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let openResults = results as? [Movie] {
                self.movieList = openResults
                
                print(self.movieList)
                self.tableView.reloadData()
            }
            if !errorMessage.isEmpty { print("Search error loading movies: " + errorMessage) }
        }
    }

}


//----------------------------------------------------------------------
// MARK: - UICollectionView
//----------------------------------------------------------------------
extension MainScreen: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewedMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ViewedCell", for: indexPath)
        
        if let movieCell = cell as? MovieCell {
            movieCell.movie = self.viewedMovies[indexPath.row]
            movieCell.play = self.openVideoPlayer
            movieCell.info = self.openSeriesInfo
            movieCell.setup()
        }
        
        return cell
    }
    
    func openVideoPlayer(movieURL: String)
    {
        // OPEN VIDEO PLAYER
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        secondViewController.url = URL(string: movieURL)
        
        self.navigationController?.pushViewController(secondViewController, animated: true)
        // OPEN VIDEO PLAYER
    }
    
    // TODO: pass a class instead of all those parameters
    func openSeriesInfo(seriesId: Int, season: Int, posterURL: String?, desc: String){
        // OPEN VIDEO PLAYER
        let seriesController = self.storyboard?.instantiateViewController(withIdentifier: "SeriesController") as! SeriesController
        
        seriesController.series_id = seriesId
        seriesController.season = season
        seriesController.posterURL = posterURL
        seriesController.decription = desc
        
        self.navigationController?.pushViewController(seriesController, animated: true)
        // OPEN VIDEO PLAYER
    }
}


//----------------------------------------------------------------------
// MARK: - UITableView
//----------------------------------------------------------------------
extension MainScreen: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return movieList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 140.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieListCell", for: indexPath)
        
        if let movieListCell = cell as? MovieListCell {
            movieListCell.movieInfo = movieList[indexPath.row]
            movieListCell.info = self.openSeriesInfo
            movieListCell.setup()
        }
        
        return cell
    }
    
}

