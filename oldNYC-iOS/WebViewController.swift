//
//  WebViewController.swift
//  oldNYC-iOS
//
//  Created by Orian Breaux and Christina Leuci.
//  Copyright © 2016 OldNYC. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet var webView:UIWebView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        if let url = URL(string: "https://docs.google.com/forms/d/16ryWDwz6W0jKRGtF6BOcebfvWCdA_Yn-c-vB6y3WqUw/viewform") {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
