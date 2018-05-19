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




class MovieCell: UICollectionViewCell {
    
    @IBOutlet weak var sub: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var stoppedAtView: UIView!
    @IBOutlet weak var duration: UIView!
    
    var play: (String) -> () = {_ in}
    var info: (Int, Int, String?, String) -> () = {_,_,_,_ in}
    var movie: Viewed?
    
    func setup(){
        if let m = movie {
            self.configureTime(duration: m.duration, stoppedAt: m.stoppedAt) // set the red bar below the viewed movie
            self.sub.text = m.label() // set S#E# or duration
            
            if let poster = m.poster {
                image.getImgFromUrl(link: poster, contentMode: UIViewContentMode.scaleAspectFit) // load poster asynchronously
            }
        }
    }
    
    // Set view width
    func configureTime(duration: Int, stoppedAt: Int)
    {
        let newWidth = self.duration.frame.width * CGFloat(Float(stoppedAt)/Float(duration))
        self.stoppedAtView.frame = CGRect(0, 0, newWidth, self.stoppedAtView.frame.height)
    }
    
    // When clicking on play movie -> execute closure
    @IBAction func playMovie(_ sender: UIButton)
    {
        if let m = movie {
          self.play(m.URL)
        }
    }
    
    // When clicking on display info -> execute closure
    @IBAction func openInfo(_ sender: UIButton)
    {
        if let m = movie {
            self.info(m.id, m.season ?? 1, m.poster, m.desc ?? "N/A")
        }
    }
}



class MovieListCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var poster: UIImageView!
    
    var movieInfo: Movie?
    var info: (Int, Int, String?, String) -> () = {_,_,_,_ in}
    
    
    func setup()
    {
        if let m = movieInfo {
            self.titleLabel.text = m.title
            self.descLabel.text = m.desc ?? "N/A"
            
            if let poster = m.poster {
                self.poster.getImgFromUrl(link: poster, contentMode: UIViewContentMode.scaleAspectFit)
            }
        }
    }
    
    // When clicking on display info -> execute closure
    @IBAction func openInfo(_ sender: UIButton)
    {
        if let m = movieInfo {
            self.info(m.id, 1, m.poster, m.desc ?? "N/A")
        }
    }
    
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
                thumbnailView.getImgFromUrl(link: thumbnail, contentMode: UIViewContentMode.scaleAspectFit)
            }
            self.title.text = "\(ep.episodeNum). \(ep.title)"
            self.duration.text = ep.durationMin()
            self.plot.text = ep.description ?? "N/A"
            
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



// SOURCE: https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
extension UIImageView {
    func getImgFromUrl(link: String, contentMode mode: UIViewContentMode) {
        let url = URL(string: link)
        self.contentMode = mode
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            
            DispatchQueue.main.async {
                if let d = data {
                self.image = UIImage(data: d)
                }
            }
        }
    }
}

extension CGRect {
    
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        
        self.init(x:x, y:y, width:w, height:h)
    }
}
