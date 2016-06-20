//
//  HomeViewController.swift
//  SSOC
//
//  Created by Nhat Truong on 6/10/16.
//  Copyright © 2016 Nhat Truong. All rights reserved.
//

import UIKit
import MBProgressHUD

class HomeViewController: UIViewController, SettingsDelegate {
    
    var spinner = MBProgressHUD()
    var timer1 = NSTimer()
    var timer2 = NSTimer()
    var timer3 = NSTimer()
    var counter = 0
    var flagDefault = Bool()
    
    @IBOutlet weak var resistorButton: UIButton!
    @IBOutlet weak var backView: UIView!
    var dataArray = [String](count: 8, repeatedValue: "0")
    var dataDelegate = [String](count: 8, repeatedValue: "0")

    var responseCode: String!
    var offResistor: Bool!
    var serialNumber: String!
    var username: String!
    var password: String!
    var istarData: NSDictionary!
    
    @IBOutlet weak var timeLabel1: UILabel!
    
    @IBOutlet weak var timeLabel3: UILabel!
    @IBOutlet weak var timeLabel2: UILabel!
    @IBOutlet weak var containerTempLabel: UILabel!
    @IBOutlet weak var waterOutputLabel: UILabel!
    @IBOutlet weak var collectorTempLabel: UILabel!
    @IBOutlet weak var graphButton: UIButton!
    @IBOutlet weak var defaultSettingsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBAction func onDefaultButton(sender: UIButton) {
        //set ve default
        timer1.invalidate()
        
        let alertVC = UIAlertController(
            title: "Mặc định",
            message: "Xác nhận chỉnh cài đặt về mặc định" ,
            preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.defaultAPI()
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style:.Default,
            handler: nil)
        
        alertVC.addAction(cancelAction)

        alertVC.addAction(okAction)

        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func defaultAPI(){
        //set cai dat ve mac dinh
        
        backView.hidden = false
        backView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        
        //chay loading
        spinner = MBProgressHUD.showHUDAddedTo(self.backView, animated: true)
        spinner.labelText = "Loading"
        spinner.detailsLabelText = "Please wait"
        spinner.userInteractionEnabled = false
        
        serialNumber = serialNumber.stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        let url = NSURL(string: "http://125.212.247.155:10010/api/istar/?user=\(username)&pass=\(password)&device=iSTAR&serial=\(serialNumber)&temp=50&timer1=8.00&timer2=11.00&timer3=16.00&timer4=19.00&timer5=21.00&timer6=22.00&dientro=true&status=true")!
        print(url)
        let request = NSMutableURLRequest(
            URL: url,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        request.HTTPMethod = "PUT"
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
            if let requestError = error{
                print("error")
            }
            if let data = dataOrNil{
                self.responseCode = String(data: data, encoding: NSUTF8StringEncoding)
                print("data: ",self.responseCode)
                if self.responseCode == "true" {
                    self.flagDefault = true
                    //chay ham checkdata de kiem tra cap nhat thanh cong chua
                    self.timer2 = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(HomeViewController.checkData), userInfo: nil, repeats: true)
                    
                } else {
                    self.timer1 = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(HomeViewController.getAPI), userInfo: nil, repeats: true)
                    self.alertShow("Fail to update", message: "")
                }
            }
        })
        task.resume()
    }
    
    @IBAction func offResistorButton(sender: UIButton) {
        
        //bat tat dien tro
        timer1.invalidate()
        offResistor = !offResistor
        dataArray[7] = "\(offResistor)"
        
        print("offResistor: ", offResistor)
        //hien thong bao xac nhan
        if offResistor == true {
            let alertVC = UIAlertController(
                title: "Bật điện trở",
                message: "Xác nhận Bật điện trở" ,
                preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                self.sendAPI(self.offResistor)
            }
            
            let cancelAction = UIAlertAction(
                title: "Cancel",
                style:.Default,
                handler: nil)
            
            alertVC.addAction(cancelAction)
            
            alertVC.addAction(okAction)
            
            self.presentViewController(alertVC, animated: true, completion: nil)


        } else {
            let alertVC = UIAlertController(
                title: "Tắt điện trở",
                message: "Xác nhận tắt điện trở" ,
                preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                self.sendAPI(self.offResistor)
            }
            
            let cancelAction = UIAlertAction(
                title: "Cancel",
                style:.Default,
                handler: nil)
            
            alertVC.addAction(cancelAction)
            
            alertVC.addAction(okAction)
            
            self.presentViewController(alertVC, animated: true, completion: nil)

        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //pass data qua cac view controller khac
        if segue.identifier == "toSettingsSegue" {
            let dvc = segue.destinationViewController as! SettingsViewController
            dvc.delegate = self
            dvc.dataArray[0] = dataArray[0]
            dvc.dataArray[1] = dataArray[1]
            dvc.dataArray[2] = dataArray[2]
            dvc.dataArray[3] = dataArray[3]
            dvc.dataArray[4] = dataArray[4]
            dvc.dataArray[5] = dataArray[5]
            dvc.dataArray[6] = dataArray[6]
                
            dvc.dataArray[7] = serialNumber
            dvc.dataArray[8] = "\(offResistor)"
            dvc.dataArray[9] = username
            dvc.dataArray[10] = password
        } else if segue.identifier == "toGraphSegue" {
            let dvc = segue.destinationViewController as! GraphViewController
            dvc.username = username
            dvc.password = password
            dvc.serialNumber = serialNumber
        }
        print("prepare for segue")
    }
    
    //dung delegate de lay data tu settingsviewcontroller
    func settingsController(settingsViewController: SettingsViewController, didUpdateSettings settings: [String]) {
        print("delegate")
        flagDefault = false

        backView.hidden = false
        backView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
       
        spinner = MBProgressHUD.showHUDAddedTo(self.backView, animated: true)
        spinner.labelText = "Loading"
        spinner.detailsLabelText = "Please wait"
        spinner.userInteractionEnabled = false
        

        dataDelegate[0] = settings[0]
        dataDelegate[1] = settings[1]
        dataDelegate[2] = settings[2]
        dataDelegate[3] = settings[3]
        dataDelegate[4] = settings[4]
        dataDelegate[5] = settings[5]
        dataDelegate[6] = settings[6]
        
        self.timer1.invalidate()
        self.timer2 = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(HomeViewController.checkData), userInfo: nil, repeats: true)

//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
//            self.timer1.invalidate()
//            dispatch_async(dispatch_get_main_queue(), {
//                self.timer2 = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(HomeViewController.checkData), userInfo: nil, repeats: true)
//
//            })
//        }
    }
    
    func checkResistor(){
        //kiem tra data tu API va data bat tat dien tro cua user de check cap nhat thanh cong
        var resistorTemp: Bool!
        getAPI()
        resistorTemp = self.istarData["A131"] as! Bool

        print("resistorTemp: ", resistorTemp)
        print("dataArray[7]: ", dataArray[7])

        if "\(resistorTemp)" == dataArray[7] {
            spinner.showAnimated(true) {
                self.backView.hidden = true
            }
            alertShow("Cập nhật thành công", message: "")

            timer3.invalidate()
            timer1 = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(HomeViewController.getAPI), userInfo: nil, repeats: true)
            
        }
        else {
            counter += 1
            
        }
        
        if counter > 6 {
            spinner.showAnimated(true) {
                self.backView.hidden = true
            }
            alertShow("Cập nhật thất bại", message: "")
            counter = 0
            timer3.invalidate()
            timer1 = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(HomeViewController.getAPI), userInfo: nil, repeats: true)
        }

    }
    
    func checkData() {
        
        //kiem tra data tu API va data settings cua user de check cap nhat thanh cong
        var dataTemp = [String](count: 7, repeatedValue: "0")
        getAPI()
        dataTemp[0] = String(format: "%.2f", self.istarData["A125"] as! Float)
        dataTemp[1] = String(format: "%.2f", self.istarData["A126"] as! Float)
        dataTemp[2] = String(format: "%.2f", self.istarData["A127"] as! Float)
        dataTemp[3] = String(format: "%.2f", self.istarData["A128"] as! Float)
        dataTemp[4] = String(format: "%.2f", self.istarData["A129"] as! Float)
        dataTemp[5] = String(format: "%.2f", self.istarData["A130"] as! Float)
        dataTemp[6] = String(format: "%.0f", self.istarData["A124"] as! Float)
        for i in 0..<dataDelegate.count {
            print("dataDelegate: ", dataDelegate[i])
        }

        for i in 0..<6 {
            if dataTemp[i].characters.count < 5 {
                dataTemp[i] = "0\(dataTemp[i])"
                print("dataTemp: ", dataTemp[i])

            }
        }

        //flag = true la cap nhat gia tri default
        //flag = false la cap nhat gia tri cua user
        if flagDefault == true {
            if dataTemp[0] == "08.00"
                && dataTemp[1] == "11.00" && dataTemp[2] == "16.00"
                && dataTemp[3] == "19.00" && dataTemp[4] == "21.00"
                && dataTemp[5] == "22.00" && dataTemp[6] == "50"{
                
                spinner.showAnimated(true) {
                    self.backView.hidden = true
                }
                alertShow("Cập nhật thành công", message: "")
                
                timer2.invalidate()
                
                timer1 = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(HomeViewController.getAPI), userInfo: nil, repeats: true)
                
            }
            else {
                counter += 1
            }

        } else {
            if dataTemp[0] == dataDelegate[0]
                && dataTemp[1] == dataDelegate[1] && dataTemp[2] == dataDelegate[2]
                && dataTemp[3] == dataDelegate[3] && dataTemp[4] == dataDelegate[4]
                && dataTemp[5] == dataDelegate[5] && dataTemp[6] == dataDelegate[6]{
                
                spinner.showAnimated(true) {
                    self.backView.hidden = true
                }
                alertShow("Cập nhật thành công", message: "")
                
                timer2.invalidate()
                
                timer1 = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(HomeViewController.getAPI), userInfo: nil, repeats: true)
                
            }
            else {
                counter += 1
            }
        }
        
        if counter > 6 {
            spinner.showAnimated(true) {
                self.backView.hidden = true
            }
            alertShow("Cập nhật thất bại", message: "")
            counter = 0
            timer2.invalidate()
            timer1 = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(HomeViewController.getAPI), userInfo: nil, repeats: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        counter = 0
        
        timer1 = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(HomeViewController.getAPI), userInfo: nil, repeats: true)

        timer2.invalidate()
        
        backView.hidden = true
        
    
        graphButton.layer.cornerRadius = 8
        graphButton.layer.borderWidth = 0.5
        graphButton.layer.borderColor = graphButton.tintColor.CGColor
        graphButton.sizeToFit()
        
        settingsButton.layer.cornerRadius = 8
        settingsButton.layer.borderWidth = 0.5
        settingsButton.layer.borderColor = settingsButton.tintColor.CGColor
        settingsButton.sizeToFit()

        defaultSettingsButton.layer.cornerRadius = 8
        defaultSettingsButton.layer.borderWidth = 0.5
        defaultSettingsButton.layer.borderColor = defaultSettingsButton.tintColor.CGColor
        defaultSettingsButton.sizeToFit()
        
        resistorButton.layer.cornerRadius = 8
        resistorButton.layer.borderWidth = 0.5
        resistorButton.layer.borderColor = settingsButton.tintColor.CGColor
        resistorButton.sizeToFit()
        
        timeLabel1.sizeToFit()
        timeLabel2.sizeToFit()
        timeLabel3.sizeToFit()
        
        collectorTempLabel.sizeToFit()
        containerTempLabel.sizeToFit()
    }
    
    override func viewWillAppear(animated: Bool) {
        getAPI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogoutButton(sender: UIBarButtonItem) {
        performSegueWithIdentifier("toLoginSegue", sender: self)
    }

    func sendAPI(resistor: Bool){

        //gui data settings cua user len API
        backView.hidden = false
        backView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        
        spinner = MBProgressHUD.showHUDAddedTo(self.backView, animated: true)
        spinner.labelText = "Loading"
        spinner.detailsLabelText = "Please wait"
        spinner.userInteractionEnabled = false
        
        serialNumber = serialNumber.stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        let url = NSURL(string: "http://125.212.247.155:10010/api/istar/?user=\(username)&pass=\(password)&device=iSTAR&serial=\(serialNumber)&temp=\(dataArray[6])&timer1=\(dataArray[0])&timer2=\(dataArray[1])&timer3=\(dataArray[2])&timer4=\(dataArray[3])&timer5=\(dataArray[4])&timer6=\(dataArray[5])&dientro=\(resistor)&status=true")!
        print(url)
        let request = NSMutableURLRequest(
            URL: url,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        request.HTTPMethod = "PUT"
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
       

        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
            if let requestError = error{
                print("error")
            }
            if let data = dataOrNil{
                self.responseCode = String(data: data, encoding: NSUTF8StringEncoding)
                print("data: ",self.responseCode)
                if self.responseCode == "true" {
                    
                    self.timer3 = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(HomeViewController.checkResistor), userInfo: nil, repeats: true)

                } else {
                    self.timer1 = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(HomeViewController.getAPI), userInfo: nil, repeats: true)
                    self.alertShow("Fail to update", message: "")
                }
            }
        })
        task.resume()
        
    }

    
    func getAPI(){
        //lay data ve tu API
        let url = NSURL(string: "http://125.212.247.155:10010/api/istar/?user=\(username)&pass=\(password)")!
        
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
                print("error")
            }
            if let data = dataOrNil{
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSArray{
                    self.istarData = responseDictionary[0] as! NSDictionary
                    print(self.istarData)
                    self.offResistor = self.istarData["A131"] as! Bool
                    
                    print("bool: ", self.offResistor)
                    
                    if self.offResistor == true {

                        self.settingsButton.enabled = true
                        self.defaultSettingsButton.enabled = true
//                        self.settingsButton.backgroundColor = UIColor(red: 216, green: 83, blue: 79, alpha: 1.0)

                        self.resistorButton.setTitle("TẮT ĐIỆN TRỞ", forState: .Normal)
                        self.defaultSettingsButton.backgroundColor = self.uicolorFromHex(0x5CB75C)
                        self.settingsButton.backgroundColor = self.uicolorFromHex(0xD8534F)

                    } else {
                        self.settingsButton.enabled = false
                        self.defaultSettingsButton.enabled = false
                        self.defaultSettingsButton.backgroundColor = UIColor.grayColor()
                        self.settingsButton.backgroundColor = UIColor.grayColor()

                        self.resistorButton.setTitle("BẬT ĐIỆN TRỞ", forState: .Normal)
                    }
                
                    var temp = self.istarData["A4"] as! Int
                    self.collectorTempLabel.text = "\(temp)℃"

                    temp = self.istarData["A0"] as! Int
                    self.waterOutputLabel.text = "\(temp)℃"

                    temp = self.istarData["A124"] as! Int
                    self.dataArray[6] = "\(temp)"
                    self.containerTempLabel.text = "\(temp)℃"

                    temp = self.istarData["Solanlap"] as! Int
//                    if temp >= 5 {
//                        self.settingsButton.enabled = false
//                        self.settingsButton.setTitle("MAT KET NOI", forState: .Normal)
//                    }
//                    else {
//                        self.settingsButton.enabled = true
//                    }
                    
                    self.dataArray[0] = String(format: "%.2f", self.istarData["A125"] as! Float)
                    self.dataArray[0] = self.dataArray[0].stringByReplacingOccurrencesOfString(".", withString: ":")
                    
                    self.dataArray[1] = String(format: "%.2f", self.istarData["A126"] as! Float)
                    self.dataArray[1] = self.dataArray[1].stringByReplacingOccurrencesOfString(".", withString: ":")
                    self.timeLabel1.text = "\(self.dataArray[0]) - \(self.dataArray[1])"
                    
                    self.dataArray[2] = String(format: "%.2f", self.istarData["A127"] as! Float)
                    self.dataArray[2] = self.dataArray[2].stringByReplacingOccurrencesOfString(".", withString: ":")

                    self.dataArray[3] = String(format: "%.2f", self.istarData["A128"] as! Float)
                    self.dataArray[3] = self.dataArray[3].stringByReplacingOccurrencesOfString(".", withString: ":")
                    self.timeLabel2.text = "\(self.dataArray[2]) - \(self.dataArray[3])"
                    
                    self.dataArray[4] = String(format: "%.2f", self.istarData["A129"] as! Float)
                    self.dataArray[4] = self.dataArray[4].stringByReplacingOccurrencesOfString(".", withString: ":")
                    
                    self.dataArray[5] = String(format: "%.2f", self.istarData["A130"] as! Float)
                    self.dataArray[5] = self.dataArray[5].stringByReplacingOccurrencesOfString(".", withString: ":")
                    self.timeLabel3.text = "\(self.dataArray[4]) - \(self.dataArray[5])"
                    
                    self.dataArray[0] = self.dataArray[0].stringByReplacingOccurrencesOfString(":", withString: ".")
                    self.dataArray[1] = self.dataArray[1].stringByReplacingOccurrencesOfString(":", withString: ".")
                    self.dataArray[2] = self.dataArray[2].stringByReplacingOccurrencesOfString(":", withString: ".")
                    self.dataArray[3] = self.dataArray[3].stringByReplacingOccurrencesOfString(":", withString: ".")
                    self.dataArray[4] = self.dataArray[4].stringByReplacingOccurrencesOfString(":", withString: ".")
                    self.dataArray[5] = self.dataArray[5].stringByReplacingOccurrencesOfString(":", withString: ".")


                }
            }
        })
        task.resume()

    }
    
    //hien thong bao
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
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }

}

extension UINavigationController {
    public override func shouldAutorotate() -> Bool {
        return true
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return (visibleViewController?.supportedInterfaceOrientations())!
    }
}

extension UIAlertController {
    
    public override func shouldAutorotate() -> Bool {
        return true
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}