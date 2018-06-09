//
//  SignIn.swift
//  playr
//
//  Created by Michel Balamou on 6/5/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import UIKit

class SignIn: UIViewController
{
    var net: NetworkModel!
    weak var lastView: MovieMenu!
    
    @IBOutlet weak var nameField: UITextField!

    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
    
    //------------------------------------------------------------------------
    // MARK: IBACTION
    //------------------------------------------------------------------------
    @IBAction func clickedEN(_ sender: UIButton)
    {
        State.shared.language = "EN"
    }
   
    @IBAction func clickedRU(_ sender: UIButton)
    {
        State.shared.language = "RU"
    }
    
    @IBAction func signIn(_ sender: UIButton)
    {
        State.shared.name = nameField.text ?? "N/A"
        State.shared.register {
            self.lastView.loadData()
            self.navigationController?.popViewController(animated: true)
        }
        State.shared.started = true // flag started -> so it doesnt run this code multiple times on touch
    }
}
