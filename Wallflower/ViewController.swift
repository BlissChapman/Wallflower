//
//  ViewController.swift
//  Wallflower
//
//  Created by Justin Loew on 11/22/15.
//  Copyright © 2015 Justin Loew. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import Alamofire

let WalgreensAPIKey = "ej1qRGcociFTwC3HFa00v3Wxra6gbwRJ"

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func addPhotoPressed(sender: AnyObject) {
        createPhotoActionSheet()
	}
	
	func sendChosenPhoto(photo: UIImage) {
		let data = UIImageJPEGRepresentation(photo, 1)!
		
		let request = NSMutableURLRequest(URL: NSURL(string: "http://wallflower.azurewebsites.net/upload")!)
		request.HTTPMethod = "POST"
		request.HTTPBody = data
		
		NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
			guard error == nil else {
				print(error!.localizedDescription)
				return
			}
			guard let data = data else {
				print("no data received in reply")
				return
			}
			
			let mosaicImage = UIImage(data: data)!
			print("got image back from server")
			
			self.sendToWalgreens(mosaicImage)
		}.resume()
	}
	
	/// Send a mosaic image to Walgreens
	func sendToWalgreens(mi: UIImage) {
		
	}
    
    
    //MARK: Photo Selection
    func determinePermissionStatus() -> (Bool){
        switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
        case AVAuthorizationStatus.Authorized:
            return true
        case AVAuthorizationStatus.Denied:
            return false
        case AVAuthorizationStatus.Restricted:
            return false
        case AVAuthorizationStatus.NotDetermined:
            var authorized = false
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted: Bool) in
                authorized = granted
            })
            return authorized
        }
    }
    
    private func createPhotoActionSheet() {
        if determinePermissionStatus() == true {
            var camera = false
            let photoActionSheet = UIAlertController(title: "", message: "", preferredStyle: .ActionSheet)
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                camera = true
                photoActionSheet.addAction(UIAlertAction(title: "Take New", style: UIAlertActionStyle.Default, handler: { action in
                    self.takeNew()
                }))
            }
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                camera = true
                photoActionSheet.addAction(UIAlertAction(title: "Choose from Photo Library", style: UIAlertActionStyle.Default, handler: { action in
                    self.selectFromLibrary()
                }))
            }
            
            if camera == false {
                noCameraAlert()
                return
            }
            photoActionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {action in
                photoActionSheet.dismissViewControllerAnimated(true, completion: nil)
            }))
//            photoActionSheet.popoverPresentationController?.barButtonItem = cameraButton
//            photoActionSheet.popoverPresentationController?.sourceView = view
            
            presentViewController(photoActionSheet, animated: true, completion: nil)
        } else {
            noCameraPermissionAlert()
        }
    }
    
    
    private func takeNew() {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let myAlertView = UIAlertView()
            myAlertView.title = "Error: Device has no camera or photo library."
            myAlertView.delegate = nil
            myAlertView.show()
        }
        let picker: UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    private func selectFromLibrary() {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let myAlertView = UIAlertView()
            myAlertView.title = "Error: Device has no photo library"
            myAlertView.delegate = nil
            myAlertView.show()
        }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    private func noCameraAlert() {
        let noCameraAlert = UIAlertController(title: "Error", message: "Device has no camera", preferredStyle: .Alert)
        noCameraAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        presentViewController(noCameraAlert, animated: true, completion: nil)
    }
    
    private func noCameraPermissionAlert() {
        let noCameraPermissionAlert = UIAlertController(title: "Permission Required", message: "We don't have permission to use your camera or photos.  Please revise your privacy settings. ", preferredStyle: .Alert)
        noCameraPermissionAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        noCameraPermissionAlert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { action in
            let appSettings: NSURL = NSURL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.sharedApplication().openURL(appSettings)
        }))
        presentViewController(noCameraPermissionAlert, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		defer {
			picker.dismissViewControllerAnimated(true, completion: nil)
		}
		guard let photo = info[UIImagePickerControllerEditedImage] as? UIImage else {
			return
		}
		sendChosenPhoto(photo)
	}
	
	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		picker.dismissViewControllerAnimated(true, completion: nil)
	}
	
	private func determinePermissionStatus(completion: (Bool) -> Void) {
		let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
		switch status {
		case .Authorized:
			completion(true)
		case .Denied, .Restricted:
			completion(false)
		case .NotDetermined:
			AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: completion)
		}
	}
}

