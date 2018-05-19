//
//  SeriesController.swift
//  playr
//
//  Created by Michel Balamou on 5/19/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation


class SeriesController: UIViewController {
    
    var series_id : Int?
    var season : Int = 1
    var episodes : [Episode] = []
    var posterURL : String?
    var decription : String = "N/A"
    
    var showGatherer: Show?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var seasonsLabel: UILabel!
    @IBOutlet weak var currSeason: UIButton!
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
        
        loadSeries()
        
        if let url = posterURL {
            poster.getImgFromUrl(link: url, contentMode: .scaleAspectFit)
        }
        
        descLabel.text = decription
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
    func loadSeries()
    {
        if let id = series_id {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        showGatherer = Show(id, onSeason: self.season)
        
        showGatherer!.load
        {
            results, errorMessage in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let openResults = results as? [Episode] {
                self.episodes = openResults
                self.tableView.reloadData()
            }
            if !errorMessage.isEmpty { print("Search error loading viewed: " + errorMessage) }
        }
        }
        else
        {
            print("Series ID was not set!")
        }
    }
    //----------------------------------------------------------------------
    // IBACTION
    //----------------------------------------------------------------------
    @IBAction func exit(_ sender: UIButton) {
        //Close Controller
    }
    
    @IBAction func changeSeason(_ sender: UIButton){
        // Change Season
        
    }
}


//----------------------------------------------------------------------
// MARK: - UITableView
//----------------------------------------------------------------------
extension SeriesController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeCell", for: indexPath)
        
        if let episodeCell = cell as? EpisodeCell {
            episodeCell.episodeData = self.episodes[indexPath.row]
            episodeCell.setup()
            episodeCell.play = self.openVideoPlayer
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 161
    }
}
