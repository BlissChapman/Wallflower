//
//  ViewController.swift
//  Wallflower
//
//  Created by Justin Loew on 11/22/15.
//  Copyright © 2015 Justin Loew. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON

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

	@IBAction func choosePhotoPressed(sender: AnyObject) {
		
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

}

extension ViewController: UIImagePickerControllerDelegate {
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

