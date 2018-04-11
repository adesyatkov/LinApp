//
//  AppDelegate.swift
//  LinApp
//
//  Created by Anton on 08.03.18.
//  Copyright © 2018 Anton. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate{
    
  var refAppDelegate: DatabaseReference!
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
       refAppDelegate = Database.database().reference(fromURL: "https://linguist-c6709.firebaseio.com/")
        
        if let err = error {
            ///Error abfangen falls falsche emailadresse usw
            print("Failed log into Google: ", err)
            return
            
        }
        else{
            
            print("Successfully logged into Google ",user)
            
            guard let idToken = user.authentication.idToken else {return}
            guard let accessToken = user.authentication.accessToken else {return}
            
            let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().signIn(with: credentials , completion: {(user,error) in
                if let err = error {
                    print("Failed to create a Firebase user with Google account: ", err)
                    if (err._code == 17012){print("Emailadresse ist schon registriert")}
                    //else if (err._code == 17011){print("Diese Emailadresse ist nicht registriert!")}
                    else{}
                    return
                }
                guard let uid = user?.uid else{return}
                
             
                //Save Data into Database
                let usersReference = self.refAppDelegate.child("User").child(uid)
                
                guard let Email = Auth.auth().currentUser?.email,let Name = Auth.auth().currentUser?.displayName, let URL = Auth.auth().currentUser?.photoURL  else{print("Form is not valid")
                    return}
                //Url in String convert
                let path:String = URL.absoluteString
                print(type(of:path))
                
                
                
                
                let values = ["email": Email ,"Name":Name,"PhotoURL": path]
                
                
                usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if err != nil {
                        
                        print(err as Any)
                        return
                        
                    }
                    
                    print("Saved User successfully into Firebase DB")
                })
                
                
                
                print("Succsessfully logged in Firebase with Google account: ", uid)
                self.window?.rootViewController!.performSegue(withIdentifier: "MainScreen", sender: nil)
                
                
            })
        }
       
    }
    

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
    
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
     
        
        // Add any custom logic here.
       
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        GIDSignIn.sharedInstance().handle(url,sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String,annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
         return handled
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

