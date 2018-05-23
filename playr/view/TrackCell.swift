//
//  TrackCell.swift
//  playr
//
//  Created by Michel Balamou on 5/10/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import UIKit
import Kingfisher

class TrackCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(path: String)
    {
        titleLabel.text = path
    }
}




// DELETE
class MovieListCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var poster: UIImageView!
    
    var movieInfo: Movie?
    var info: (Int, Int, String?, String) -> () = {_,_,_,_ in}
    

}


class EpisodeCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var plot: UILabel!
    
    @IBOutlet weak var stoppedAtView: UIView!
    @IBOutlet weak var durationView: UIView!
    
    var episodeData: Episode?
    var play: (String) -> () = {_ in}
    
    func setup()
    {
        if let ep = episodeData {
            if let thumbnail = ep.thumbnail{
                thumbnailView.loadCache(link: thumbnail, contentMode: UIViewContentMode.scaleAspectFit)
            }
            self.title.text = "\(ep.episode). \(ep.title ?? "N/A")"
            self.duration.text = ep.durationMin()
            self.plot.text = ep.plot
            
            self.configureTime()
        }
    }
    
    @IBAction func playEpisode(_ sender: UIButton)
    {
        if let ep = episodeData {
            self.play(ep.URL)
        }
    }
    
    // Set view width
    func configureTime()
    {
        if let ep = episodeData, let stoppedAt = ep.stoppedAt  {
            let newWidth = self.durationView.frame.width * CGFloat(Float(stoppedAt)/Float(ep.duration))
            self.stoppedAtView.frame = CGRect(0, 0, newWidth, self.stoppedAtView.frame.height)
           
            self.stoppedAtView.isHidden = false
        }
        else{
            // hide duration time bar
            self.duration.isHidden = true
        }
    }
}





