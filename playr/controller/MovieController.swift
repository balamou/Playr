//
//  MovieController.swift
//  playr
//
//  Created by Michel Balamou on 5/10/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation
import UIKit

class MovieController: UIViewController
{
    var currentPath: String = "movies"
    var searchResults: [String] = []
    //let queryService = QueryService()
    @IBOutlet weak var tableView: UITableView!
    
    
    //----------------------------------------------------------------------
    // METHODS
    //----------------------------------------------------------------------
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
    
    func filesInPath()
    {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        queryService.getSearchResults(searchTerm: currentPath)
//        {
//            results, errorMessage in
//
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            if let results = results {
//                self.searchResults = results
//                self.tableView.reloadData()
//                self.tableView.setContentOffset(CGPoint.zero, animated: false)
//            }
//            if !errorMessage.isEmpty { print("Search error: " + errorMessage) }
//        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
       super.viewWillAppear(animated)
        
       //self.navigationController?.isNavigationBarHidden = true
        filesInPath()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}





//----------------------------------------------------------------------
// MARK: - UITableView
//----------------------------------------------------------------------
extension MovieController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: TrackCell = tableView.dequeueReusableCell(withIdentifier: "track cell", for: indexPath) as! TrackCell
        
        let track = searchResults[indexPath.row]
        cell.configure(path: track)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 62.0
    }
    
    // When user taps cell, play the local file, if it's downloaded
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let selectedPath = searchResults[indexPath.row]
        let nextPath = currentPath + "/" + selectedPath
        
        
        // CHECK IF VIDEO -> OPEN MOVIE PLAYER
        let filename: NSString = nextPath as NSString
        let pathExtention = filename.pathExtension
        
        if pathExtention=="mkv" || pathExtention=="avi" || pathExtention=="mp4"
        {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            //secondViewController.url = "http://192.168.15.108/" + nextPath
            
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
        else {
            // ~> otherwise keep going
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "MovieController") as! MovieController
            secondViewController.currentPath = nextPath
            
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

