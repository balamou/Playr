//
//  ViewController.swift
//  playr
//
//  Created by Michel Balamou on 5/10/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import UIKit

class ViewController: UIViewController, VLCMediaPlayerDelegate {
    
    //------------------------- Outlets ------------------------------------
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var timeDisplay: UILabel!
    @IBOutlet weak var pausePlayBtn: UIButton!
    @IBOutlet weak var tools: UIView!
    @IBOutlet weak var topBar: UIView!
    
    @IBOutlet weak var titleButton: UIButton!
    
    //------------------------ Attributes ----------------------------------
    var movieView: UIView!
    var mediaPlayer = VLCMediaPlayer()
    var url = "http://192.168.15.108/movies/rick_and_morty/season_1/S1E1.mp4"
    
    var _setPosition = true
    var updatePosition = true
    var toolBarShown = true
    
    
    var stoppedAt = 0
    var duration = 1
    var viewedTitle = "Back"
    
    var viewing: Viewed?
    var net: NetworkModel!
    
    var timer = Timer()
    
    //----------------------------------------------------------------------
    // METHODS
    //----------------------------------------------------------------------
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Add rotation observer
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        //Setup movieView
        self.movieView = UIView()
        self.movieView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.movieView.frame = UIScreen.screens[0].bounds
        
        //Add tap gesture to movieView for show/hide tools
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.movieViewTapped(_:)))
        self.movieView.addGestureRecognizer(gesture)
        
        //Add movieView to view controller
        self.view.addSubview(self.movieView)
        self.view.sendSubview(toBack: self.movieView)
        
        // CHANGE ORIENTATION
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight, andRotateTo: UIInterfaceOrientation.landscapeRight)
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
    
    // SET TITLE
    func setTitle(viewed: Viewed)
    {
        var tmpTitle = "Back"
        
        if let ep = viewed as? Episode {
            if let s = ep.mainSeries,
                let t = s.title
            {
                tmpTitle = "\(t) S\(ep.season):E\(ep.episode) \"\(ep.title ?? "N/A")\"" // Rick and Morty S1:E1 "Pilot"
            }
            else
            {
                tmpTitle = "S\(ep.season):E\(ep.episode) \"\(ep.title ?? "N/A")\"" // S1:E1 "Pilot"
            }
        }
        else if let mov = viewed as? Movie {
            tmpTitle = mov.title ?? "Back"
        }
       
        self.viewedTitle = tmpTitle
    }
    
    //----------------------------------------------------------------------
    // CONTROLLER LIFE CYCLE
    //----------------------------------------------------------------------
    override func viewDidAppear(_ animated: Bool)
    {
        guard let url = URL(string: self.url) else {
            print("Something is wrong with URL: \(self.url)")
            return
        }
        
        // hide nav bar
        self.navigationController?.isNavigationBarHidden = true
        
        // setup title
        titleButton.setTitle(viewedTitle, for: .normal)
        
        // setup gradient
        setupGradient()
        
        let media = VLCMedia(url: url)
        mediaPlayer.media = media
        
        mediaPlayer.delegate = self
        mediaPlayer.drawable = self.movieView
        
        mediaPlayer.addObserver(self, forKeyPath: "time", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
        
        movieView.frame = self.view.frame // fill in movie view
        
        // start playing
        mediaPlayer.play()
        pausePlayBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        
        if stoppedAt != 0 {
            mediaPlayer.position = Float(stoppedAt)/Float(duration)
        }
        
         scheduledTimerWithTimeInterval()
    }
    @objc func canRotate() -> Void {}
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        mediaPlayer.removeObserver(self, forKeyPath: "time") // remove observer
        mediaPlayer.stop()
        
        // RESET ORIENTATION
        if (self.isMovingFromParentViewController)
        {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    //----------------------------------------------------------------------
    // TIMER
    //----------------------------------------------------------------------
    func scheduledTimerWithTimeInterval()
    {
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.updateStop), userInfo: nil, repeats: true)
    }
    
    @objc func updateStop()
    {
        print("Updating stop..")
        if let viewing = viewing {
            net.updateStoppedAt(viewed: viewing, stopAt: Int(mediaPlayer.position * Float(duration)) )
            
            let t = Int(mediaPlayer.position * Float(duration))
            print("\(t)")
        }
    }
    //----------------------------------------------------------------------
    // GRADIENT
    //----------------------------------------------------------------------
    func setupGradient()
    {
        // BOTTOM BAR
        let gradient = CAGradientLayer()
        
        gradient.frame = tools.bounds
        gradient.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0.5).cgColor]
        
        tools.layer.insertSublayer(gradient, at: 0)
        
        // TOP BAR
        let gradientTop = CAGradientLayer()
        
        gradientTop.frame = topBar.bounds
        gradientTop.colors = [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
        
        topBar.layer.insertSublayer(gradientTop, at: 0)
        
    }
    
   
    //----------------------------------------------------------------------
    // Orientation observer
    //----------------------------------------------------------------------
    @objc func rotated()
    {
        let orientation = UIDevice.current.orientation
        
        if (UIDeviceOrientationIsLandscape(orientation)) {
            print("Switched to landscape")
        }
        else if(UIDeviceOrientationIsPortrait(orientation)) {
            print("Switched to portrait")
        }
        
        //Always fill entire screen
        if let movieViewTmp = movieView {
            movieViewTmp.frame = self.view.frame
        }
    }
    
    //----------------------------------------------------------------------
    // Show/Hide tools
    //----------------------------------------------------------------------
    @objc func movieViewTapped(_ sender: UITapGestureRecognizer)
    {
        self.setNeedsStatusBarAppearanceUpdate()
        if toolBarShown {
            tools.isHidden = true
            topBar.isHidden = true
            UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelStatusBar // Hide status bar
        }
        else {
             tools.isHidden = false
             topBar.isHidden = false
             UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelNormal // Show the status bar
        }
        
        toolBarShown = !toolBarShown
    }
    
 
    
    //----------------------------------------------------------------------
    // GO BACK
    //----------------------------------------------------------------------
    @IBAction func goBack(_ sender: UIButton)
    {
        updateStop() // update stopped At
        // close Controller
        self.navigationController?.popViewController(animated: true)
    }
    
    //----------------------------------------------------------------------
    // Pause/Play
    //----------------------------------------------------------------------
    @IBAction func pausePlay(_ sender: UIButton)
    {
        // PAUSE
        if mediaPlayer.isPlaying
        {
            mediaPlayer.pause()
            sender.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            
            // console ----
            let remaining = mediaPlayer.remainingTime.description
            let time = mediaPlayer.time.description
            
            print("Paused at \(time) with \(remaining) time remaining")
        }
        // PLAY
        else {
            mediaPlayer.play()
            sender.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
            print("Playing")
        }
    }
    
    //----------------------------------------------------------------------
    // Slider
    //----------------------------------------------------------------------
    // continuously update slider and time displayed
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (_setPosition && updatePosition)
        {
            self.slider.value = mediaPlayer.position // move slider
            
            var remaining =  mediaPlayer.remainingTime.description
            remaining.remove(at: remaining.startIndex)
            self.timeDisplay.text = remaining // display time
        }
    }
    
    // WHEN THE VALUE FOR THE SLIDER IS SET
    @IBAction func touchUpOutside(_ sender: UISlider) {
        positionSliderAction()
        print("SET!")
    }

    @IBAction func touchUpInside(_ sender: UISlider) {
        positionSliderAction()
        print("SET!")
    }
    
    // When the slider is touched
    @IBAction func touchDown(_ sender: UISlider) {
         print("TOUCH DOWN!")
         updatePosition = false
    }
    
    func positionSliderAction()
    {
        //_resetIdleTimer()
        self.perform(#selector(_setPositionForReal), with: nil, afterDelay: 0.3)
        
        _setPosition = false
        updatePosition = true
    }
    
    @objc func _setPositionForReal()
    {
        if (!_setPosition)
        {
            mediaPlayer.position = slider.value;
            _setPosition = true;
        }
    }
    
    // Update time label as slider is moving
    @IBAction func valueChanged(_ sender: UISlider)
    {
        //let conv:VLCTime = VLCTime.init(int: Int32(sender.value))
        //timeDisplay.text = conv.description
    }
    
    @IBAction func rewind(_ sender: UIButton) {
        mediaPlayer.jumpBackward(Int32(10))
    }
    

}



