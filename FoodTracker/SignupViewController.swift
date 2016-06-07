//
//  SignupViewController.swift
//  FoodTracker
//
//  Created by Anton Moiseev on 2016-06-06.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the title
        title = "Sign up"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Actions
    @IBAction func signUp(sender: UIButton) {
        if passwordTextField.text?.characters.count < 6 {
            let alert = UIAlertController.init(title: "Warning!", message: "Enter a proper password!", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.Default, handler:nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
        } else {
            let postData = [
                "username": usernameTextField.text ?? "",
                "password": passwordTextField.text ?? ""
            ]
            
            guard let postJSON = try? NSJSONSerialization.dataWithJSONObject(postData, options: []) else {
                print("could not serialize json")
                return
            }
            
            let req = NSMutableURLRequest(URL: NSURL(string:"http://159.203.243.24:8000/signup")!)
            req.HTTPBody = postJSON
            req.HTTPMethod = "POST"
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(req) { (data, resp, err) in
                
                guard let data = data else {
                    print("no data returned from server \(err)")
                    return
                }
                
                guard let resp = resp as? NSHTTPURLResponse else {
                    print("no response returned from server \(err)")
                    return
                }
                
                guard let rawJson = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary else {
                    print("data returned is not json, or not valid")
                    return
                }
                
                guard resp.statusCode == 200 else {
                    // handle error
                    print("an error occurred \(rawJson["error"])")
                    if resp.statusCode == 409 {
                        dispatch_async(dispatch_get_main_queue(), {
                            let alert = UIAlertController.init(title: "Hey there!", message: "This user already exists. Go to log in?", preferredStyle: UIAlertControllerStyle.Alert)
                            let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.Default, handler:nil)
                            let loginAction = UIAlertAction.init(title: "Go to log in", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
                                self.performSegueWithIdentifier("loginFromSignupSegue", sender: nil)
                            })
                            alert.addAction(cancelAction)
                            alert.addAction(loginAction)
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                    }
                    return
                }
                
                // do something with the data returned (decode json, save to user defaults, etc.)
                
                let userDefaults = NSUserDefaults.standardUserDefaults()
                
                let user = rawJson["user"] as! NSDictionary
                
                userDefaults.setObject(user, forKey: "user")
                
                print("saved to user defaults")
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                })
            }
            
            task.resume()
            
        }
    }
}