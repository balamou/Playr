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





// SOURCE: https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
extension UIImageView {
    
    func loadCache(link: String, contentMode mode: UIViewContentMode)
    {
        let url = URL(string: link)!
        self.contentMode = mode
        self.kf.setImage(with: url)
    }
    
    
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
