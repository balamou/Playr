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
        tableView.reloadData()
        
        // SET TABLE HEIGHT
        let newHeight = CGFloat(161 * (series.episodes[series.openSeason]?.count)!)
        tableView.frame = CGRect(tableView.frame.minX, tableView.frame.minY, tableView.frame.width, newHeight)
        scrollView.contentSize = CGSize(width: seriesInfView.frame.width, height: seriesInfView.frame.height + newHeight)
        
        // Add blur background poster
        genBlurBackground()
        
        // GENERATE seasons buttons
        genButtons(numOfBtn: series.numSeasons)
    }
    
   
    override func viewWillAppear(_ animated: Bool)
    {
         // HIDE NAV BAR
        self.navigationController?.isNavigationBarHidden = true
        
        // SET STATUS BAR TO LIGHT
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
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
            
            let btn: UIButton = UIButton(frame: CGRect(x: 100, y: y, width: 100, height: h))
            btn.backgroundColor = UIColor.green
            btn.setTitle("Season \(season)", for: .normal)
            btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            btn.tag = season
      
            selectSeasons.addSubview(btn) // add button to as subview
        }
        
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
    
   
    //----------------------------------------------------------------------
    // MARK: IBACTION
    //----------------------------------------------------------------------
    @IBAction func exit(_ sender: UIButton) {
        // show nav bar
        self.navigationController?.isNavigationBarHidden = false
        //Close Controller
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
        tableView.reloadData() // Reload episodes in table
        currSeason.setTitle("Season \(sender.tag)", for: .normal) // CHANGE button title
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
    
    func openVideoPlayer(movieURL: String)
    {
        // OPEN VIDEO PLAYER
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        secondViewController.url = movieURL
        
        self.navigationController?.pushViewController(secondViewController, animated: true)
        // OPEN VIDEO PLAYER
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 161
    }
}
