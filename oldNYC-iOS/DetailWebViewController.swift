import UIKit
import Foundation

class DetailWebViewController: UIViewController {
    var photoIDPassed : String?
    @IBOutlet var webView:UIWebView!
    
    override func viewWillAppear(animated: Bool) {
        if let url = NSURL(string: "http://digitalcollections.nypl.org/items/image_id/" + photoIDPassed!) {
            let request = NSURLRequest(URL: url)
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