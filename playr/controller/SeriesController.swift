//
//  SeriesController.swift
//  playr
//
//  Created by Michel Balamou on 5/19/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation


class SeriesController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var seasonsLabel: UILabel!
    @IBOutlet weak var currSeason: UIButton!
    
    var show: Series!
    var selectedSeason = 1
    //----------------------------------------------------------------------
    // MARK: METHODS
    //----------------------------------------------------------------------
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        descLabel.text = show.desc
        
        if let url = show.poster
        {
            poster.loadCache(link: url, contentMode: .scaleAspectFit)
        }
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
    // MARK: IBACTION
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
        if let episodes = show.episodes[selectedSeason] {
            return episodes.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeCell", for: indexPath)
        
        if let episodeCell = cell as? EpisodeCell,
            let episode = show.episodes[selectedSeason]?[indexPath.row]
        {
            episodeCell.episode = episode
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
