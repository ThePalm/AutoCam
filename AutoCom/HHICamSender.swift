//
//  HHICamSender.swift
//  HHICam
//
//  Created by Lewis W. Johnson on 3/20/15.
//  Copyright (c) 2015 Hamiltonholt.com. All rights reserved.
//
//  this class seems a little wierd at first because the task.resume at the bottom actually executes the http request, then the completion block
//  above the task.resume() executes when the web service responds.

import UIKit
import Foundation

class HHICamSender: NSObject
{
    
    
    func post(imageguid: String, imageData: NSData)
    {
        
    var objurl: NSURL!
    var urlString: String!
    var channelString: String!
        
        
    urlString = "http://hamiltonholt.com/"
        
    var channelNumber:Int?
        
    channelNumber = NSUserDefaults.standardUserDefaults().integerForKey("channel")
        
    if (channelNumber == nil)
    {
        channelNumber = 0
        channelString = channelNames[channelNumber!]
        // put an alert to select channel here
    }
    else
    {
        channelString = channelNames[channelNumber!]
    }

    urlString = urlString + channelString + "/" + imageguid
        
    objurl = NSURL(string:urlString )
    
    var request = NSMutableURLRequest(URL:objurl )
    var session = NSURLSession.sharedSession()
        
    request.HTTPMethod = "POST"
    
    request.HTTPBody = imageData
    
    var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
        
        var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
        println("data: \(strData)")
        
        println("response: \(response)")
        
        if (error != nil)
        {
            println("error: \(error.localizedDescription)")
            
        }
        
        let httpResponse = response as! NSHTTPURLResponse
        
        if(httpResponse.statusCode >= 400 && httpResponse.statusCode <= 405)
        {
            println("Need to re-auth")
        }
        if(httpResponse.statusCode >= 200 && httpResponse.statusCode <= 204)
        {
            println("success-------")
            println(httpResponse.statusCode)

        }
        else
        {
            println("fail----------");
            println(httpResponse.statusCode)
        }
        
            })
    
    task.resume()
    
    
    }

    deinit
    {
     println("An instance of sender is being deinitialized")
    
        
    }
}
