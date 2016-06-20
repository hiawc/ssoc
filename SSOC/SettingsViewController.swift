//
//  SettingsViewController.swift
//  SSOC
//
//  Created by Nhat Truong on 6/11/16.
//  Copyright © 2016 Nhat Truong. All rights reserved.
//

import UIKit

protocol SettingsDelegate: class {
    func settingsController(settingsViewController: SettingsViewController, didUpdateSettings settings: [String])
}

class SettingsViewController: UIViewController {
    
    weak var delegate: SettingsDelegate!

    var dataArray = [String](count: 11, repeatedValue: "0")
    var istarData: NSDictionary!

    var responseCode: String!
    
    @IBOutlet weak var containterTempLabel: UILabel!
    @IBOutlet weak var timeLabel6: UILabel!
    @IBOutlet weak var timeLabel5: UILabel!
    @IBOutlet weak var timeLabel4: UILabel!
    @IBOutlet weak var timeLabel3: UILabel!
    @IBOutlet weak var timeLabel1: UILabel!
    @IBOutlet weak var timeLabel2: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    
    
    @IBAction func onCancelUpdate(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func subString() {
        //kiem tra dieu kien thoi gian settings
        var hourInt = [Int](count:6, repeatedValue:0)
        var minuteInt = [Int](count:6, repeatedValue:0)
        var counter = 0
        for i in 0..<6 {
            let index = dataArray[i].characters.indexOf(".")!
            let stringHour = dataArray[i].substringToIndex(index)
            let stringMinute = dataArray[i].substringFromIndex(index.advancedBy(1))
            if let temp = NSNumberFormatter().numberFromString(stringHour){
                hourInt[i] = temp.integerValue
                print("hourInt: ", hourInt[i])
            }
            if let temp = NSNumberFormatter().numberFromString(stringMinute){
                minuteInt[i] = temp.integerValue
                print("minuteInt: ", minuteInt[i])
            }

        }
        
        
        
        if hourInt[0] > hourInt[1] || hourInt[1] > hourInt[2]
            || hourInt[2] > hourInt[3] || hourInt[3] > hourInt[4] || hourInt[4] > hourInt[5] {
            alertShow("time wrong", message: "")
        } else {
            if hourInt[0] == hourInt[1] {
                if minuteInt[0] > minuteInt[1] {
                    alertShow("Wrong minute", message: "")
                }
                else {
                    counter += 1
                }
            }
            else {
                counter += 1
            }

            if hourInt[1] == hourInt[2] {
                if minuteInt[1] >= minuteInt[2] {
                    alertShow("Wrong minute", message: "")
                }
                else {
                    counter += 1
                }
            }
            else {
                counter += 1
            }

            if hourInt[2] == hourInt[3] {
                if minuteInt[2] > minuteInt[3] {
                    alertShow("Wrong minute", message: "")
                }
                else {
                    counter += 1
                }
            }
            else {
                counter += 1
            }

            if hourInt[3] == hourInt[4] {
                if minuteInt[3] >= minuteInt[4] {
                    alertShow("Wrong minute", message: "")
                }
                else {
                    counter += 1
                }
            }
            else {
                counter += 1
            }

            if hourInt[4] == hourInt[5] {
                if minuteInt[4] > minuteInt[5] {
                    alertShow("Wrong minute", message: "")
                }
                else {
                    counter += 1
                }
            }
            else {
                counter += 1
            }

            
            if counter == 5 {
                sendAPI()
            }
        }
    }

    func onTimeChanged(sender: UITapGestureRecognizer) {
        //chon cac khoang thoi gian
        let dateFormat = NSDateFormatter()
        let tag = sender.view!.tag 

        DatePickerDialog().show("Chọn khoảng thời gian", doneButtonTitle: "Done", cancelButtonTitle: "Cancel" , datePickerMode: .Time) { (date) -> Void in
            dateFormat.timeStyle = NSDateFormatterStyle.ShortStyle
            dateFormat.dateFormat = "HH:mm"
    
            var time = dateFormat.stringFromDate(date)
            switch tag {
                case 1:
                    self.timeLabel1.text = time
                    time = time.stringByReplacingOccurrencesOfString(":", withString: ".")
                    self.dataArray[0] = time
                    print(self.dataArray[0])
                case 2:
                    self.timeLabel2.text = time
                    time = time.stringByReplacingOccurrencesOfString(":", withString: ".")
                    self.dataArray[1] = time
                    print(self.dataArray[1])

                case 3:
                    self.timeLabel3.text = time
                    time = time.stringByReplacingOccurrencesOfString(":", withString: ".")
                    self.dataArray[2] = time
                    print(self.dataArray[2])

                case 4:
                    self.timeLabel4.text = time
                    time = time.stringByReplacingOccurrencesOfString(":", withString: ".")
                    self.dataArray[3] = time
                    print(self.dataArray[3])

                case 5:
                    self.timeLabel5.text = time
                    time = time.stringByReplacingOccurrencesOfString(":", withString: ".")
                    self.dataArray[4] = time
                    print(self.dataArray[4])

                case 6:
                    self.timeLabel6.text = time
                    time = time.stringByReplacingOccurrencesOfString(":", withString: ".")
                    self.dataArray[5] = time
                    print(self.dataArray[5])

                default: break
            }
        }
    }
    
    @IBAction func onUpdateSettings(sender: UIButton) {
        subString()
    }
    
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var temp = dataArray[0].stringByReplacingOccurrencesOfString(".", withString: ":")
        timeLabel1.text = temp
        
        temp = dataArray[1].stringByReplacingOccurrencesOfString(".", withString: ":")
        timeLabel2.text = temp
        
        temp = dataArray[2].stringByReplacingOccurrencesOfString(".", withString: ":")
        timeLabel3.text = temp
        
        temp = dataArray[3].stringByReplacingOccurrencesOfString(".", withString: ":")
        timeLabel4.text = temp
        
        temp = dataArray[4].stringByReplacingOccurrencesOfString(".", withString: ":")
        timeLabel5.text = temp
        
        temp = dataArray[5].stringByReplacingOccurrencesOfString(".", withString: ":")
        timeLabel6.text = temp
        
        containterTempLabel.text = "\(dataArray[6])℃"

        updateButton.layer.cornerRadius = 8
        updateButton.layer.borderWidth = 0.5
        updateButton.layer.borderColor = updateButton.tintColor.CGColor
        
        cancelButton.layer.cornerRadius = 8
        cancelButton.layer.borderWidth = 0.5
        cancelButton.layer.borderColor = cancelButton.tintColor.CGColor
        
        //add action vao label
        let tapTime1 = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.onTimeChanged(_:)))
        let tapTime2 = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.onTimeChanged(_:)))
        let tapTime3 = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.onTimeChanged(_:)))
        let tapTime4 = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.onTimeChanged(_:)))
        let tapTime5 = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.onTimeChanged(_:)))
        let tapTime6 = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.onTimeChanged(_:)))
        
        let tapTemp = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.onTempChanged(_:)))
        
        timeLabel1.addGestureRecognizer(tapTime1)
        timeLabel2.addGestureRecognizer(tapTime2)
        timeLabel3.addGestureRecognizer(tapTime3)
        timeLabel4.addGestureRecognizer(tapTime4)
        timeLabel5.addGestureRecognizer(tapTime5)
        timeLabel6.addGestureRecognizer(tapTime6)
        containterTempLabel.addGestureRecognizer(tapTemp)
        
        timeLabel1.tag = 1
        timeLabel2.tag = 2
        timeLabel3.tag = 3
        timeLabel4.tag = 4
        timeLabel5.tag = 5
        timeLabel6.tag = 6

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

    func onTempChanged(sender: UITapGestureRecognizer){
        //chon nhiet do bon
        let tempData = [
            ["value" : "30" , "display" : "30℃"], ["value" : "31" , "display" : "31℃"],
            ["value" : "32" , "display" : "32℃"], ["value" : "33" , "display" : "33℃"],
            ["value" : "34" , "display" : "34℃"], ["value" : "35" , "display" : "35℃"],
            ["value" : "36" , "display" : "36℃"], ["value" : "37" , "display" : "37℃"],
            ["value" : "38" , "display" : "38℃"], ["value" : "39" , "display" : "39℃"],
            ["value" : "40" , "display" : "40℃"], ["value" : "41" , "display" : "41℃"],
            ["value" : "42" , "display" : "42℃"], ["value" : "43" , "display" : "43℃"],
            ["value" : "44" , "display" : "44℃"], ["value" : "45" , "display" : "45℃"],
            ["value" : "46" , "display" : "46℃"], ["value" : "47" , "display" : "47℃"],
            ["value" : "48" , "display" : "48℃"], ["value" : "49" , "display" : "49℃"],
            ["value" : "50" , "display" : "50℃"], ["value" : "51" , "display" : "51℃"],
            ["value" : "52" , "display" : "52℃"], ["value" : "53" , "display" : "53℃"],
            ["value" : "54" , "display" : "54℃"], ["value" : "55" , "display" : "55℃"],
            ["value" : "56" , "display" : "56℃"], ["value" : "57" , "display" : "57℃"],
            ["value" : "58" , "display" : "58℃"], ["value" : "59" , "display" : "59℃"],
            ["value" : "60" , "display" : "60℃"], ["value" : "61" , "display" : "61℃"],
            ["value" : "62" , "display" : "62℃"], ["value" : "63" , "display" : "63℃"],
            ["value" : "64" , "display" : "64℃"], ["value" : "65" , "display" : "65℃"],
            ["value" : "66" , "display" : "66℃"], ["value" : "67" , "display" : "67℃"],
            ["value" : "68" , "display" : "68℃"], ["value" : "69" , "display" : "69℃"],
            ["value" : "70" , "display" : "70℃"], ["value" : "71" , "display" : "71℃"],
            ["value" : "72" , "display" : "72℃"], ["value" : "73" , "display" : "73℃"],
            ["value" : "74" , "display" : "74℃"], ["value" : "75" , "display" : "75℃"],
            ["value" : "76" , "display" : "76℃"], ["value" : "77" , "display" : "77℃"],
            ["value" : "78" , "display" : "78℃"], ["value" : "79" , "display" : "79℃"],

        ]
        
        PickerDialog().show("Nhiệt độ bồn", doneButtonTitle: "OK", cancelButtonTitle: "Cancel", options: tempData, selected: self.dataArray[6]) { (value) -> Void in
            self.dataArray[6] = value
            self.containterTempLabel.text = "\(value)℃"
        }
    }

    func sendAPI(){
        //gui API settings ve
        dataArray[7] = dataArray[7].stringByReplacingOccurrencesOfString(" ", withString: "+")
        let url = NSURL(string: "http://125.212.247.155:10010/api/istar/?user=\(dataArray[9])&pass=\(dataArray[10])&device=iSTAR&serial=\(dataArray[7])&temp=\(dataArray[6])&timer1=\(dataArray[0])&timer2=\(dataArray[1])&timer3=\(dataArray[2])&timer4=\(dataArray[3])&timer5=\(dataArray[4])&timer6=\(dataArray[5])&dientro=\(dataArray[8])&status=true")!
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
                if self.responseCode == "true"{
                    //copy data vao delegate de pass sang homeviewcontroller
                    var settings = [String](count: 7, repeatedValue: "0")
                    for i in 0..<7 {
                        settings[i] = self.dataArray[i]
                    }

                    self.delegate?.settingsController(self, didUpdateSettings: settings)
                    self.dismissViewControllerAnimated(true, completion: nil)

                }
            }
        })
        task.resume()

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
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

}
