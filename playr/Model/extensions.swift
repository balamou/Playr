//
//  extensions.swift
//  playr
//
//  Created by Michel Balamou on 5/23/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {

    // Source: https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
    func loadCache(link: String, contentMode mode: UIViewContentMode)
    {
        let url = URL(string: link)!
        self.contentMode = mode
        self.kf.setImage(with: url)
    }
    
    
    // Non cashing loading of images
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
