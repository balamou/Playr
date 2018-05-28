//
//  MovieInfo.swift
//  playr
//
//  Created by Michel Balamou on 5/25/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation


class MovieInfo: UIViewController {
    
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    var movie: Movie?
    var net: NetworkModel!
    
    //----------------------------------------------------------------------
    // MARK: METHODS
    //----------------------------------------------------------------------
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard let mov = movie else {return}
        
        titleLabel.text = mov.title ?? "N/A"
        descLabel.text = mov.desc ?? "N/A"
        
        if let poster = mov.poster {
            posterView.loadCache(link: poster, contentMode: .scaleAspectFit)
        }
    }
    
    @IBAction func playMovie(_ sender: UIButton)
    {
        if let mov = movie
        {
            let videoPlayer = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            
            videoPlayer.url = mov.URL
            videoPlayer.stoppedAt = mov.stoppedAt ?? 0
            videoPlayer.duration = mov.duration
            
            self.navigationController?.pushViewController(videoPlayer, animated: true)
        }
    }
    
    @IBAction func exit(_ sender: UIButton)
    {
        // TODO: EXIT MOVIE INFO BUTTON
    }

}

