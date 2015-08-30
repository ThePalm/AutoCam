//
//  HHICamSettingsViewController.swift
//  HHICam
//
//  Created by Lewis W. Johnson on 3/23/15.
//  Copyright (c) 2015 Hamiltonholt.com. All rights reserved.
//

import UIKit

class HHICamSettingsViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate
{

    @IBOutlet weak var uipickChannel: UIPickerView!
    
    @IBOutlet weak var uipickinterval: UIPickerView!
    let intervalNames = ["OFF","10 Seconds","20 Seconds","30 Seconds","40 Seconds","50 Seconds","60 Seconds"]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        uipickChannel.dataSource = self
        uipickChannel.delegate = self
        
        uipickinterval.dataSource = self
        uipickinterval.delegate = self

    }
    
    override func viewWillAppear(animated: Bool)
    {
        var channelNumber:Int?
 
       channelNumber = NSUserDefaults.standardUserDefaults().integerForKey("channel")
        
        if (channelNumber == nil)      //Check for first run of app
        {
            channelNumber = 0
        }
        
        uipickChannel .selectRow(channelNumber!, inComponent: 0, animated: true)
        
        var intervalNumber:Int?
        
        intervalNumber = NSUserDefaults.standardUserDefaults().integerForKey("interval")
        
        uipickinterval .selectRow(intervalNumber!, inComponent: 0, animated: true)
        
        if (channelNumber == nil)      //Check for first run of app
        {
            intervalNumber = 1
        }

        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if pickerView == uipickinterval {return intervalNames.count}
        if pickerView == uipickChannel {return channelNames.count}
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        if pickerView == uipickinterval {return intervalNames[row]}
        if pickerView == uipickChannel {return channelNames[row]}
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        //myLabel.text = pickerData[row]
        if pickerView == uipickinterval
        {
            NSUserDefaults.standardUserDefaults().setInteger(row, forKey: "interval")
        }
        
        if pickerView == uipickChannel
        {
            NSUserDefaults.standardUserDefaults().setInteger(row, forKey: "channel")
        }
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
