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
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    var episode: Episode!
    var play: (Viewed) -> () = {_ in}
    
    func setup()
    {
        if let thumbnail = episode.thumbnail{
            thumbnailView.loadCache(link: thumbnail, contentMode: UIViewContentMode.scaleAspectFit)
        }
        
        self.title.text = "\(episode.episode). \(episode.title ?? "N/A")"
        self.duration.text = episode.durationMin()
        self.plot.text = episode.plot
        
        self.title.sizeToFit()
        //self.plot.sizeToFit()
        
        self.configureTime()
    }
    
    @IBAction func playEpisode(_ sender: UIButton)
    {
        self.play(episode)
    }
    
    // Set view width
    func configureTime()
    {
        if let stoppedAt = episode.stoppedAt, episode.duration != 0 {
            
            let newWidth = self.durationView.frame.width * CGFloat(Float(stoppedAt)/Float(episode.duration))
            widthConstraint.constant = newWidth
            self.stoppedAtView.layoutIfNeeded()
            //self.stoppedAtView.frame = CGRect(0, 0, newWidth, self.stoppedAtView.frame.height)
           
            self.durationView.isHidden = false
            //self.stoppedAtView.setNeedsLayout()
        }
        else{
            // hide duration time bar
            self.durationView.isHidden = true
            self.stoppedAtView.setNeedsLayout()
        }
    }
}





