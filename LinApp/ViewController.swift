//
//  ViewController.swift
//  LinApp
//
//  Created by Anton on 08.03.18.
//  Copyright © 2018 Anton. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

//Sign out implement
//automatische login wenn angemeldet




class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    var ref: DatabaseReference!
    var ProfileURL : String = ""
    @IBOutlet weak var ProfileImage: UIImageView!
    
    var UserID: Int = 0
    
    @IBOutlet weak var Email_Textbar: UITextField!
    
    @IBOutlet weak var Password_Textbar: UITextField!
    
    @IBAction func Logout(_ sender: Any) {
        
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        //gehe zu anmelde-Menue!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
        print(Auth.auth().currentUser)
    }
    
    
    @IBAction func ClickMeToSignIn(_ sender: Any) {
        
    //Versuche einzuloggen wenn nicht klappt informiere den Nutzer
        
        guard let Email = Email_Textbar.text,let Password = Password_Textbar.text else{print("Form is not valid")
            return}
        
        Auth.auth().signIn(withEmail: Email, password: Password) { (user, error) in
            if let err = error {
                
                //Fehlercode Abfangen und Nutzer benachrichtigen!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                print("Failed to log in with Email account: ", err)
                
                if (err._code == 17009){print("wrong Emailadress or Password")}
                else if (err._code == 17011){print("Diese Emailadresse ist nicht registriert!")}
                else{}
                
                return
            }
            else{
                        //ist die Email bestätigt?
                        if (Auth.auth().currentUser?.isEmailVerified == true){
                
                            print("Successfully Signed in")
                            
/////!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Download USER Profile Picture
                            
                            
self.performSegue(withIdentifier: "MainScreen", sender: nil)
                
                
                        }
                        else{print("Bitte bestätige deine Email Adresse!")}
            }
          
        }
        

        
        
    }
    
    
    @IBAction func Register(_ sender: Any) {
        
        guard let Email = Email_Textbar.text,let Password = Password_Textbar.text else{print("Form is not valid")
            return}
        
        // Upload Picture to Firebase
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("ProfileImages").child("\(imageName).png")
        
        if let uploadData = UIImagePNGRepresentation(self.ProfileImage.image!){
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print(error)
                    return
                }
                Auth.auth().createUser(withEmail: Email , password: Password) { (user: User?, error) in
                    if let err = error {
                        print("Failed to create a Firebase user with Email account: ", err)
                        return
                    }
                    //get user UID
                    guard let uid = user?.uid else{return}
                    
                self.ProfileURL = (metadata?.downloadURL()?.absoluteString)!
                //Save User in Database
                let usersReference = self.ref.child("User").child(uid)
                let values = ["email":Email,"PhotoURL":self.ProfileURL]
                print(values)
                print(type(of:values))
                usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if err != nil {
                        
                        print(err as Any)
                        return
                        
                    }
                    
                    print("Saved User successfully into Firebase DB")
                })
                    
                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                        if let err = error {
                            print("Failed to send a user an verification Email: ", err)
                            return
                        }
                        
                        let firebaseAuth = Auth.auth()
                        do {
                            try firebaseAuth.signOut()
                        } catch let signOutError as NSError {
                            print ("Error signing out: %@", signOutError)
                        }
                        
                        
                        
                        print("Please check your emails and verified your account! ")
                        
                    }
            }
            
        }
        
        
      
       
            
     
        
        
        }}
    
    func getFBData(){
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email"]).start(completionHandler: { (connection, result, error) in
            if (error != nil){
                print(result)
                return
                
            }
            var dict : NSDictionary!
            dict = result as! NSDictionary
            var id = dict.object(forKey: "id") as! String
            self.UserID = Int(id)!
            print(self.UserID)
            
          self.loadPicture()
            
            
        })
    
    
    
    
    
    
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            
            return
            
            
        }
        
        print("Successfully logged in with Facebook")
        //get FB infos
        
        
        
        
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else {return}
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials , completion: {(user,error) in
            if let err = error {
                print("Failed to create a Firebase user with FB account: ", err)
                //log out
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                //log out finish
                return
    }
            print("Succsessfully logged in Firebase with FB account: ")
            
            //get User Infos
            
            
            guard let uid = user?.uid else{return}
            //Save Data into Database
            let usersReference = self.ref.child("User").child(uid)
            
            
            self.getFBData()
            
            
            guard let Email = Auth.auth().currentUser?.email,let Name = Auth.auth().currentUser?.displayName, let URL = Auth.auth().currentUser?.photoURL  else{print("Form is not valid")
                return}
            //Url in String convert
            let path:String = URL.absoluteString
            print(type(of:path))
            
            print(Auth.auth().currentUser?.providerID)
            
        
            
            
            let values = ["email": Email ,"Name":Name,"PhotoURL": path]
            
           
            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {

                    print(err as Any)
                    return

                }

                print("Saved User successfully into Firebase DB")
            })
            
            
           // self.performSegue(withIdentifier: "MainScreen", sender: nil)
     
    })
    
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of Facebook")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        
        
        //Database
        
        ref = Database.database().reference(fromURL: "https://linguist-c6709.firebaseio.com/")
        //ref = delegate.refAppDelegate
      
        
        
        //
        //ref.updateChildValues([])
        
        //check if user is not logged in
checkIfUserIsLoggedIn()
        
        //Kategorie Aktien aus Firebase Laden
        
        
        print(Auth.auth().currentUser)
        ref.child("Aktien").child("Diversifikation").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            dump(value)
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
       
        
        //foto manuell laden
        
        ProfileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        ProfileImage.isUserInteractionEnabled = true
        
        //Display photo man muss angemeldet sein sonst gibts fette dicke Fehler
        if (Auth.auth().currentUser != nil){
//loadPicture()
        }
        //Facebook
    
        let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        
        loginButton.frame = CGRect(x: 16, y: 400, width: view.frame.width - 32, height: 50)
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]   //ermöglicht Zugriff auf Email adresse
    
        //Google
        
        let googleButton = GIDSignInButton()
        
        googleButton.frame = CGRect(x: 16, y: 400 + 66, width: view.frame.width - 32, height: 50)
        view.addSubview(googleButton)
        //googleButton.delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
       // GIDSignIn.sharedInstance().delegate = self
        
        
        
    }
    
  
    func loadPicture(){
        
        let profileImageUrl = Auth.auth().currentUser?.photoURL
        
//        var facebookProfileUrl = "http://graph.facebook.com/\(UserID)/picture?type=large"
//        let idURL = URL(string: facebookProfileUrl)
//
        print(type(of: profileImageUrl))
        
        URLSession.shared.dataTask(with: profileImageUrl!, completionHandler: { (data, response, error) in
            if error != nil{
                print(error)
                return
            }
            DispatchQueue.main.async { // Make sure you're on the main thread here
            self.ProfileImage.image = UIImage(data: data!)
            }
            
        }).resume()
    }
    func checkIfUserIsLoggedIn(){
        
        if Auth.auth().currentUser?.uid == nil {
//perform(#selector(Logout), with: nil, afterDelay: 0)
//print("PERFORM LOGOUT")
        }else{
            
            
            
            // ziehe Datenbank Kategorie runter
            Database.database().reference().child("Kategorien").observeSingleEvent(of: .value, with: { (snapshot) in
                
                print(snapshot)
                //if let dictionary = snapshot.value as?[String: AnyObject]{
                  //  self.navigationItem.title = dictionary["name"] as? String
               //}
        }, withCancel: nil)
            
            
            let uid = Auth.auth().currentUser?.uid
            
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                print(snapshot)
                //if let dictionary = snapshot.value as?[String: AnyObject]{
                //  self.navigationItem.title = dictionary["name"] as? String
                //}
            }, withCancel: nil)
            
            
            
            
        }
        
        
        
        
    }
        

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

