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
    
    @IBOutlet weak var selectSeasons: UIView!
    
    @IBOutlet weak var seriesInfView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var show: Series?
    var series_id: Int!
    var net: NetworkModel!
    
    //----------------------------------------------------------------------
    // MARK: METHODS
    //----------------------------------------------------------------------
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        net.loadFullSeries(series_id: series_id, completion: setupData)
    }
    
    func setupData(_ series: Series)
    {
        self.show = series
        
        descLabel.text = series.desc
        currSeason.setTitle("Season \(series.openSeason)", for: .normal)
        
        if let url = series.poster
        {
            poster.loadCache(link: url, contentMode: .scaleAspectFit)
        }
        
        
        seasonsLabel.text = "\(series.numSeasons) seasons"
        
        // SET TABLE HEIGHT & SCROLL CONTENT SIZE
        var newHeight = 0
        if let episodes = series.episodes[series.openSeason]
        {
            for ep in episodes
            {
                if let plot=ep.plot, plot == "" {
                    newHeight+=90
                }
                else
                {
                    newHeight+=160
                }
            }
        }
        
        //let newHeight = CGFloat(161 * (series.episodes[series.openSeason]?.count)!)
        tableView.frame = CGRect(tableView.frame.minX, tableView.frame.minY, tableView.frame.width, CGFloat(newHeight))
        scrollView.contentSize = CGSize(width: seriesInfView.frame.width, height: seriesInfView.frame.height + CGFloat(newHeight))
        
        // Add blur background poster
        genBlurBackground()
        
        // GENERATE seasons buttons
        genButtons(numOfBtn: series.numSeasons)
        
        // Reload episode table
        tableView.reloadData()
        tableView.setNeedsLayout()
    }
    
   
    override func viewWillAppear(_ animated: Bool)
    {
        // HIDE NAV BAR
        self.navigationController?.isNavigationBarHidden = true
        
        // SET STATUS BAR TO LIGHT
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    
    //----------------------------------------------------------------------
    // GENERATE BLUR BACKGROUND & GRADIENT
    //----------------------------------------------------------------------
    private func genBlurBackground()
    {
        let frm = CGRect(frame: seriesInfView.frame, newHeight: seriesInfView.frame.height - CGFloat(50.0))
        
        // BLUR
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = frm
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // POSTER +++++
        let bkgPoster = UIImageView(frame: frm)
        //bkgPoster.insetsLayoutMarginsFromSafeArea = false
        
        if let show = self.show,
           let url = show.poster
        {
            bkgPoster.loadCache(link: url, contentMode: .scaleToFill)
        }
        
        // GRADIENT ++++
        let gradient = CAGradientLayer()
        let gradHeight = CGFloat(50.0)
        
        gradient.frame = CGRect(seriesInfView.frame.minX, frm.height - gradHeight, seriesInfView.frame.width, gradHeight)
        gradient.colors = [UIColor.black.withAlphaComponent(0).cgColor, #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1).cgColor] // UIColor.black.cgColor
        
        // ADD VIEWS
        seriesInfView.addSubview(blurEffectView)
        seriesInfView.addSubview(bkgPoster)
        bkgPoster.layer.insertSublayer(gradient, at: 0)
        
        seriesInfView.sendSubview(toBack: blurEffectView)
        seriesInfView.sendSubview(toBack: bkgPoster)
    }
    
    //----------------------------------------------------------------------
    // GENERATE SEASON BUTTONS
    //----------------------------------------------------------------------
    private func genButtons(numOfBtn: Int)
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        selectSeasons.addSubview(blurEffectView)
        selectSeasons.sendSubview(toBack: blurEffectView)
        
        for season in 1...numOfBtn
        {
            let h: CGFloat = 50
            let y: CGFloat = (100 + (h + 10) * CGFloat(season))
            
            let btn: UIButton = UIButton(frame: CGRect(x: 137, y: y, width: 100, height: h))
            //btn.backgroundColor = UIColor.green
            btn.setTitle("Season \(season)", for: .normal)
            btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            btn.tag = season
            
            if let show = self.show, season == show.openSeason {
                //btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                btn.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 19)
            }
      
            selectSeasons.addSubview(btn) // add button to as subview
        }
        
    }
    
    
    //----------------------------------------------------------------------
    // MARK: STOP ROTATION ANIMATION
    //----------------------------------------------------------------------
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        coordinator.animate(alongsideTransition: nil) { (_) in
            UIView.setAnimationsEnabled(true)
        }
        UIView.setAnimationsEnabled(false)
        super.viewWillTransition(to: size, with: coordinator)
    }
    
}


//----------------------------------------------------------------------
// MARK: IBACTION
//----------------------------------------------------------------------
extension SeriesController
{

    @IBAction func exit(_ sender: UIButton)
    {
        // show nav bar
        self.navigationController?.isNavigationBarHidden = false
        // close Controller
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeSeason(_ sender: UIButton)
    {
        // Change Season
        selectSeasons.isHidden = false // TODO: Maybe add animation instead of hidden/shown
        
    }
    
    @IBAction func closeSeasonSelector(_ sender: UIButton)
    {
        selectSeasons.isHidden = true // TODO: Maybe add animation instead of hidden/shown
    }
    
    @objc func buttonAction(_ sender: UIButton!)
    {
        guard let show = show else { return }
        
        selectSeasons.isHidden = true // TODO: Maybe add animation instead of hidden/shown
        show.openSeason = sender.tag // SELECT Different season
        currSeason.setTitle("Season \(sender.tag)", for: .normal) // CHANGE button title
        
        // UI: Change button boldness
        for tag in 1...show.numSeasons {
            let tmpButton = self.selectSeasons.viewWithTag(tag) as? UIButton
            //tmpButton?.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            tmpButton?.titleLabel?.font = UIFont(name: "HelveticaNeue-Regular", size: 19)
           
        }
        
        //sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18) // make current button bold
        sender.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 19) // make current button bold
        
        // UI: SET TABLE HEIGHT & SCROLL CONTENT SIZE
        let newHeight = CGFloat(161 * (show.episodes[show.openSeason]?.count)!)
        tableView.frame = CGRect(tableView.frame.minX, tableView.frame.minY, tableView.frame.width, newHeight)
        scrollView.contentSize = CGSize(width: seriesInfView.frame.width, height: seriesInfView.frame.height + newHeight)
        
        tableView.reloadData() // Reload episodes in table
    }
}




//----------------------------------------------------------------------
// MARK: - UITableView
//----------------------------------------------------------------------
extension SeriesController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let show = show,
            let episodes = show.episodes[show.openSeason]
        {
            return episodes.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeCell", for: indexPath) as! EpisodeCell
        
        
        if let show = show,
            let seasons = show.episodes[show.openSeason]
        {
            cell.episode = seasons[indexPath.row]
            cell.setup()
            cell.play = self.openVideoPlayer
        }
        
        return cell
    }

    
    // MARK: OPEN VIDEO PLAYER
    func openVideoPlayer(viewed: Viewed)
    {
        let videoPlayer = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        videoPlayer.viewing = viewed
        videoPlayer.net = net
        
        self.navigationController?.pushViewController(videoPlayer, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if let show = show, let episodes = show.episodes[show.openSeason],
            let plot = episodes[indexPath.row].plot, plot == ""
        {
            return 90
        }
        else
        {
            return 161
        }
    }
}
