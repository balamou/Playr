//
//  TrackCell.swift
//  playr
//
//  Created by Michel Balamou on 5/10/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import UIKit


class TrackCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(path: String)
    {
        titleLabel.text = path
    }
}






class EpisodeCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var plot: UILabel!
    
    @IBOutlet weak var stoppedAtView: UIView!
    @IBOutlet weak var durationView: UIView!
    
    var episode: Episode!
    var play: (String) -> () = {_ in}
    
    func setup()
    {
        if let thumbnail = episode.thumbnail{
            thumbnailView.loadCache(link: thumbnail, contentMode: UIViewContentMode.scaleAspectFit)
        }
        
        self.title.text = "\(episode.episode). \(episode.title ?? "N/A")"
        self.duration.text = episode.durationMin()
        self.plot.text = episode.plot
        
        self.configureTime()
    }
    
    @IBAction func playEpisode(_ sender: UIButton)
    {
        self.play(episode.URL)
    }
    
    // Set view width
    func configureTime()
    {
        if let stoppedAt = episode.stoppedAt  {
            let newWidth = self.durationView.frame.width * CGFloat(Float(stoppedAt)/Float(episode.duration))
            self.stoppedAtView.frame = CGRect(0, 0, newWidth, self.stoppedAtView.frame.height)
           
            self.stoppedAtView.isHidden = false
        }
        else{
            // hide duration time bar
            self.duration.isHidden = true
        }
    }
}





