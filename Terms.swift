//
//  Terms.swift
//  joke
//
//  Created by Mehrshad JM on 2/18/17.
//  Copyright © 2017 Mehrshad Jalilmasir. All rights reserved.
//

import UIKit
import M13Checkbox

class Terms: UIViewController {

    @IBOutlet weak var termShow: UILabel!
    
    
    
    @IBOutlet var CHB: M13Checkbox!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        termShow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.shows)))
        
        CHB.boxLineWidth = 2
        CHB.cornerRadius = 0
        CHB.checkmarkLineWidth = 2
        CHB.layer.masksToBounds = true
        CHB.checkState = M13Checkbox.CheckState.checked
        CHB.stateChangeAnimation = .bounce(.fill)
    }
    
    func shows()
    {
        //print("terms")
        PopupController
            .create(self)
            .show(DemoPopupViewController1.instance())
    }
    
    
    @IBAction func chbCheked(_ sender: Any) {
        
        if CHB.checkState == M13Checkbox.CheckState.checked
        {
            confirmTerms = true
        }
        else
        {
            confirmTerms = false
        }
        //print(confirmTerms)
    }
}
