//
//  MovieMenu.swift
//  playr
//
//  Created by Michel Balamou on 5/21/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation


class MovieMenu: UIViewController{
    
    var categories = ["Viewed", "Movies", "Series"]
    
    var viewRow = 0
    var movieRow = 1
    var seriesRow = 2
    
    var net = NetworkModel()
    
    @IBOutlet weak var categoryTable: UITableView!
    
    
    //----------------------------------------------------------------------
    // METHODS
    //----------------------------------------------------------------------
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let dummyViewHeight = CGFloat(40)
        
        // Disable flotable headers:
        // https://stackoverflow.com/questions/1074006/is-it-possible-to-disable-floating-headers-in-uitableview-with-uitableviewstylep
        self.categoryTable.tableHeaderView = UIView(frame: CGRect(0, 0, self.categoryTable.bounds.size.width, dummyViewHeight))
        self.categoryTable.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0)
        
        net.displayInfo = self.openSeriesInfo
        net.play = self.openVideoPlayer
        
        net.loadViewed(completion: self.reloadView)
        net.loadMovies(completion: self.reloadMovies)
        net.loadSeries(completion: self.reloadSeries)
        
    }
    
    // MARK: On completion
    func reloadView(err: String)
    {
        let viewedRow = categoryTable.cellForRow(at: IndexPath(row:0, section: viewRow)) as! ViewedRow
        viewedRow.collectionCell.reloadData()
    }
    
    func reloadMovies(err: String)
    {
        let categoryRow = categoryTable.cellForRow(at: IndexPath(row:0, section: movieRow)) as! CategoryRow
        categoryRow.collectionCell.reloadData()
    }
    
    func reloadSeries(err: String)
    {
        let categoryRow = categoryTable.cellForRow(at: IndexPath(row:0, section: seriesRow)) as! CategoryRow
        categoryRow.collectionCell.reloadData()
    }
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        // SET STATUS BAR TO LIGHT
        UIApplication.shared.statusBarStyle = .lightContent
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
    

    // MARK: OPEN VIDEO PLAYER
    func openVideoPlayer(_ viewed: Viewed)
    {
        let videoPlayer = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        videoPlayer.url = viewed.URL
        videoPlayer.stoppedAt = viewed.stoppedAt ?? 0
        videoPlayer.duration = viewed.duration

        self.navigationController?.pushViewController(videoPlayer, animated: true)
    }

    // MARK: DISPLAY SERIES INFO
    func openSeriesInfo(_ viewed: Any){
        
        if let ep = viewed as? Episode,
           let series = ep.mainSeries
        {
            
            let seriesController = self.storyboard?.instantiateViewController(withIdentifier: "SeriesController") as! SeriesController
            seriesController.series_id = series.series_id
            seriesController.net = net
            
            self.navigationController?.pushViewController(seriesController, animated: true)
        }
        else if let series = viewed as? Series
        {
            let seriesController = self.storyboard?.instantiateViewController(withIdentifier: "SeriesController") as! SeriesController
            seriesController.series_id = series.series_id
            seriesController.net = net
            
            self.navigationController?.pushViewController(seriesController, animated: true)
        }
        else if let movie = viewed as? Movie
        {
            let movieInfo = self.storyboard?.instantiateViewController(withIdentifier: "MovieInfo") as! MovieInfo
            movieInfo.movie = movie
    
            self.navigationController?.pushViewController(movieInfo, animated: true)
        }
    }
}



// --------------------------------------------------------------------------
// MARK: TABLE VIEW
// --------------------------------------------------------------------------

extension MovieMenu: UITableViewDataSource, UITableViewDelegate
{
    // CHANGE HEADER TEXT TO WHITE & CHANGE HEADER BACKGROUND
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection: Int)
    {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.white // change text color
            view.tintColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1) // change background color
        }
    }
    
   

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }
    
  
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == viewRow {
            return 200 // viewed height
        }
        else
        {
            return 160 // movie/series height
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if indexPath.section == viewRow {
            let viewedCell = tableView.dequeueReusableCell(withIdentifier: "ViewedRow") as! ViewedRow
            viewedCell.net = net
            
            return viewedCell
        }
        else
        {
            let categoryCell = tableView.dequeueReusableCell(withIdentifier: "CategoryRow") as! CategoryRow
            categoryCell.net = net
            
            if indexPath.section == movieRow {
                categoryCell.rowType = "Movie"
            }
            else if indexPath.section == seriesRow {
            categoryCell.rowType = "Series"
            }
                
            return categoryCell
        }
    }
}


