//
//  GraphViewController.swift
//  SSOC
//
//  Created by Nhat Truong on 6/16/16.
//  Copyright © 2016 Nhat Truong. All rights reserved.
//

import UIKit
import Charts
import MBProgressHUD

class GraphViewController: UIViewController {
    
    var spinner = MBProgressHUD()

    var waterOutputTemp = [Double]()
    var collectorTemp = [Double]()
    var time = [String]()
    var istarData: [NSDictionary]?
    var username = String()
    var password = String()
    var serialNumber = String()
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    func setChart(time: [String], values1: [Double], values2: [Double]){
        var dataEntries1: [ChartDataEntry] = [ChartDataEntry]()
        var dataEntries2: [ChartDataEntry] = [ChartDataEntry]()

        for i in 0..<time.count {
            dataEntries1.append(ChartDataEntry(value: values1[i], xIndex: i))
        }
        for i in 0..<time.count {
            dataEntries2.append(ChartDataEntry(value: values2[i], xIndex: i))
        }
        let chartDataSet1 = LineChartDataSet(yVals: dataEntries1, label: "Nhiet do bon")
        chartDataSet1.axisDependency = .Left
        chartDataSet1.setColor(UIColor.redColor().colorWithAlphaComponent(0.5))
        chartDataSet1.setCircleColor(UIColor.redColor())
        chartDataSet1.lineWidth = 1.0
        chartDataSet1.circleRadius = 1.0
//        chartDataSet1.fillAlpha = 65/255.0
        chartDataSet1.fillColor = UIColor.redColor()
        chartDataSet1.highlightColor = UIColor.whiteColor()
//        chartDataSet1.drawCircleHoleEnabled = true
        
        let chartDataSet2 = LineChartDataSet(yVals: dataEntries2, label: "Nhiet do nuoc dau ra")
    
        chartDataSet2.axisDependency = .Left
        chartDataSet2.setColor(UIColor.greenColor().colorWithAlphaComponent(0.5))
        chartDataSet2.setCircleColor(UIColor.greenColor())
        chartDataSet2.lineWidth = 1.0
        chartDataSet2.circleRadius = 1.0
//        chartDataSet2.fillAlpha = 65/255.0
        chartDataSet2.fillColor = UIColor.greenColor()
        chartDataSet2.highlightColor = UIColor.whiteColor()
//        chartDataSet2.drawCircleHoleEnabled = true

        
        
        var dataSets: [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(chartDataSet1)
        dataSets.append(chartDataSet2)

        let chartData = LineChartData(xVals: time, dataSets: dataSets)
        lineChartView.leftAxis.axisMinValue = chartDataSet1.yMin
        lineChartView.leftAxis.axisMaxValue = chartDataSet1.yMax + 10

        lineChartView.rightAxis.axisMinValue = chartDataSet1.yMin
        lineChartView.rightAxis.axisMaxValue = chartDataSet1.yMax + 10

        
        lineChartView.data = chartData
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinner.labelText = "Loading"
        spinner.detailsLabelText = "Please wait"
        spinner.userInteractionEnabled = false
        getAPI()
       

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getAPI(){
        serialNumber = serialNumber.stringByReplacingOccurrencesOfString(" ", withString: "+")

        let url = NSURL(string: "http://125.212.247.155:10010/api/istar/?user=\(username)&pass=\(password)&serial=\(serialNumber)")!
        print(url)
        let request = NSURLRequest(
            URL: url,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 20)
        
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
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? [NSDictionary]{
                    print("count: ", responseDictionary.count)
                    self.istarData = responseDictionary
                    
                   
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
                        let temp = responseDictionary.count - 1
                        for i in 0..<responseDictionary.count {
                            self.waterOutputTemp.append(self.istarData![temp-i]["A0"] as! Double)
                            self.collectorTemp.append(self.istarData![temp-i]["A4"] as! Double)
                            let hour = self.istarData![temp-i]["Gio"] as! String
                            let minute = self.istarData![temp-i]["Phut"] as! String
                            self.time.append("\(hour):\(minute)")
//                            print("water: ", self.waterOutputTemp)
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            self.setChart(self.time, values1: self.collectorTemp, values2: self.waterOutputTemp)
                            self.spinner.hide(true)
                        })
                    }

                    
                    
                }
            }
        })
        task.resume()

    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
   
}
