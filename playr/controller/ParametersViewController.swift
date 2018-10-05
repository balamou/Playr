//
//  ParametersViewController.swift
//  playr
//
//  Created by Michel Balamou on 2018-07-30.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import UIKit

class ParametersViewController: UIViewController
{
    @IBOutlet weak var buttonEN: UIButton!
    @IBOutlet weak var buttonRU: UIButton!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        if  State.shared.language == "EN"
        {
            buttonEN.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18) // make the button bold
            buttonRU.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        }
        else
        {
            buttonRU.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18) // make the button bold
            buttonEN.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        }
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func selectEN(sender: Any)
    {
        State.shared.language = "EN"
        State.shared.save()
        State.shared.load()
        
        buttonEN.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18) // make the button bold
        buttonRU.titleLabel?.font = UIFont.systemFont(ofSize: 18)
    }
    
    @IBAction func selectRU(sender: Any)
    {
        State.shared.language = "RU"
        State.shared.save()
        State.shared.load()
        
        buttonRU.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18) // make the button bold
        buttonEN.titleLabel?.font = UIFont.systemFont(ofSize: 18)
    }

}
