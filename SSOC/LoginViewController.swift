//
//  LoginViewController.swift
//  SSOC
//
//  Created by Nhat Truong on 6/10/16.
//  Copyright © 2016 Nhat Truong. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    var login: NSDictionary!
    var returnSerial: String!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    
    @IBAction func onLoginButton(sender: UIButton) {

        //check username, password
        if usernameText.text == "" || passwordText.text == ""{
            alertShow("Lỗi", message: "Hãy nhập tên đăng nhập/mật khẩu")
        }
        else {
            var urlTemp = "http://125.212.247.155:10010/api/clperson/?user=\(usernameText.text!)&pass=\(passwordText.text!)"
            urlTemp = urlTemp.stringByReplacingOccurrencesOfString(" ", withString: "+")
            let url = NSURL(string: urlTemp)!
            print(url)
            let request = NSURLRequest(
                URL: url,
                cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
                timeoutInterval: 10)
            
            let session = NSURLSession(
                configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                delegate: nil,
                delegateQueue: NSOperationQueue.mainQueue()
            )
            
            let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
                if let requestError = error{
                    self.alertShow("Lỗi", message: "Không thể kết nối tới server")

                }
                if let data = dataOrNil{
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary{
                        //lay API ve theo dang JSON roi paste vo NSDictionary
                        let login = responseDictionary as NSDictionary
                        let returnCode = login["returnCode"] as? Int
                        if returnCode == 0 {
                            self.returnSerial = login["returnSerial"] as! String
                            print("returnSerial: ", self.returnSerial)
                            self.performSegueWithIdentifier("toHomeViewController", sender: self)
                        } else if returnCode == -1 {
                            self.alertShow("Sai tên đăng nhập", message: "Kiểm tra lại tên đăng nhập")
                        } else if returnCode == 1 {
                            self.alertShow("Sai mật khẩu", message: "Kiểm tra lại mật khẩu")
                        }
                    }
                }
            })
            task.resume()
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //pass data qua homeviewcontroller
        let navigationViewController = segue.destinationViewController as! UINavigationController
        let homeViewController = navigationViewController.topViewController as! HomeViewController
        homeViewController.serialNumber = returnSerial
        homeViewController.username = usernameText.text
        homeViewController.password = passwordText.text
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 15
        loginButton.layer.borderWidth = 0.5
        loginButton.layer.borderColor = loginButton.tintColor.CGColor
        loginButton.layer.backgroundColor = UIColor.blueColor().CGColor
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertShow(title: String, message: String) {
        let alertVC = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .Alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.Default,
            handler: nil)
        alertVC.addAction(okAction)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }

}
