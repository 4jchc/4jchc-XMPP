//
//  ViewController.swift
//  XMPP
//
//  Created by 蒋进 on 15/12/20.
//  Copyright © 2015年 sijichcai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

            // 做注销
        let app: AppDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
            app.logout()
            
        }
    }


