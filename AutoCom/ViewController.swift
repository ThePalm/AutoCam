//
//  ViewController.swift
//  HHICam
//
//  Created by Lewis W. Johnson on 3/20/15.
//  Copyright (c) 2015 Hamiltonholt.com. All rights reserved.
//
import UIKit
import AVFoundation

let channelNames = ["URL1","URL2","URL3","URL4","URL5","URL6","URL7","URL8","URL9","URL10"]


class ViewController: UIViewController
{
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    var savedintervalNumber:Int!
    var picintervalValueInSeconds:Double!
    var intervalNumber:Int!
    var running:Bool?
    var timer: NSTimer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        intervalNumber = NSUserDefaults.standardUserDefaults().integerForKey("interval")
        savedintervalNumber = intervalNumber
        
        if intervalNumber == 0 // zero means "OFF" but it needs a default value to get it to go check the parm
            // within the loop so the user can change the value without the need for a restart
        {
            timer = NSTimer.scheduledTimerWithTimeInterval( 10, target: self, selector:Selector("TakePhotos"), userInfo:nil, repeats: true)
        }
        else
        {
            performIntervalCheck()
            timer = NSTimer.scheduledTimerWithTimeInterval( picintervalValueInSeconds, target: self, selector:Selector("TakePhotos"), userInfo:nil, repeats: true)
        }
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        
        running==false
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        //var backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error: NSError?
        //var input = AVCaptureDeviceInput(device: backCamera, error: &error)
        var input = AVCaptureDeviceInput(device: captureDevice, error: &error)
        
        
        if error == nil && captureSession!.canAddInput(input)
        {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput)
            {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewView.layer.addSublayer(previewLayer)
                
                captureSession!.startRunning()
            }
        }
        
        var channelNumber:Int!
        var obj:AnyObject?
        
        obj = NSUserDefaults.standardUserDefaults().objectForKey("channel") //have to use the Anyobject test because we store the channel number as an int
        //.integerForKey will return a zero if the channel user default is not there
        //and zero is a valid index in our array of strings.
        
        channelNumber = NSUserDefaults.standardUserDefaults().integerForKey("channel")
        
        if (obj == nil)
        {
            channelNumber = 0
            alert("First Run of App",message:"This is the first run of this App. Please go to Settings and choose a Channel")
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        previewLayer!.frame = previewView.bounds //comment out to use simulator, it does not have a camera and this will blow
    }
    
    @IBAction func didPressTakePhoto(sender: AnyObject)
    {
        if(running != true)
        {
            [takePhotoButton .setTitle("Stop", forState: UIControlState())]
            running=true
        }
        else
        {
            [takePhotoButton .setTitle("Capture", forState: UIControlState())]
            running=false
        }
        
    }
    
    func configureDevice()
    {
        if let device = captureDevice
        {
            device.lockForConfiguration(nil)
            device.focusMode = .Locked
            device.unlockForConfiguration()
        }
    }
    
    func TakePhotos()
    {
        performIntervalCheck()
        
        if(running==true)
        {
            if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo)
            {
                
                videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
                stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                    if (sampleBuffer != nil)
                    {
                        var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                        
                        // data to transmit
                        var imagedata64:NSData
                        imagedata64 = imageData.base64EncodedDataWithOptions(.allZeros)
                        
                        // data to render
                        var dataProvider = CGDataProviderCreateWithCFData(imageData)
                        var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, kCGRenderingIntentDefault)
                        var image = UIImage(CGImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.Right)
                        self.capturedImage.image = image
                        
                        
                        var sender = HHICamSender()
                        let struuid = NSUUID().UUIDString
                        sender.post(struuid,imageData: imagedata64)
                    }
                })
            }
        }
    }
    
    func StopPhotos()
    {
        
        
    }
    
    
    
    func focusTo(value : Float)
    {
        if let device = captureDevice
        {
            if(device.lockForConfiguration(nil))
            {
                device.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
                    //
                })
                device.unlockForConfiguration()
            }
        }
    }
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    
    
    func alert(title: String, message: String)
    {
        if let getModernAlert: AnyClass = NSClassFromString("UIAlertController") { // iOS 8
            let myAlert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            myAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(myAlert, animated: true, completion: nil)
        } else { // iOS 7
            let alert: UIAlertView = UIAlertView()
            alert.delegate = self
            
            alert.title = title
            alert.message = message
            alert.addButtonWithTitle("OK")
            
            alert.show()
        }
    }
    
    func performIntervalCheck()
    {
        intervalNumber = NSUserDefaults.standardUserDefaults().integerForKey("interval")
        
        if intervalNumber != savedintervalNumber
        {
            timer!.invalidate()
            
            
            
            switch intervalNumber {
                
            case 0:
                picintervalValueInSeconds = 0
            case 1:
                picintervalValueInSeconds = 10
            case 2:
                picintervalValueInSeconds = 20
            case 3:
                picintervalValueInSeconds = 30
            case 4:
                picintervalValueInSeconds = 40
            case 5:
                picintervalValueInSeconds = 50
            case 6:
                picintervalValueInSeconds = 60
                
                
            default:
                picintervalValueInSeconds = 0
                
            }
            
            timer = NSTimer.scheduledTimerWithTimeInterval( picintervalValueInSeconds, target: self, selector:Selector("TakePhotos"), userInfo:nil, repeats: true)
            
            savedintervalNumber = intervalNumber
            
        }
        else
        {
            switch intervalNumber {
                
            case 0:
                picintervalValueInSeconds = 0
            case 1:
                picintervalValueInSeconds = 10
            case 2:
                picintervalValueInSeconds = 20
            case 3:
                picintervalValueInSeconds = 30
            case 4:
                picintervalValueInSeconds = 40
            case 5:
                picintervalValueInSeconds = 50
            case 6:
                picintervalValueInSeconds = 60
                
                
            default:
                picintervalValueInSeconds = 0
                
            }
            
        }
        
    }
    
}
