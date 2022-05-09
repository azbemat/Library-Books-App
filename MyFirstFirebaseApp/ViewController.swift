//
//  ViewController.swift
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class ViewController: UIViewController {
    
    // reference to firestore database
    let db = Firestore.firestore()
    
    var users:[User] = []
    var loggedInUser = ""

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var lblErrorMsg: UILabel!
    
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        // get the value in the text box
        let usernameInput = txtUsername.text!
        let passwordInput = txtPassword.text!

        
        var isUserFound = validateUser(givenUsername: usernameInput, givenPassword: passwordInput)
        
        if(isUserFound){
            self.lblErrorMsg.text = ""

            // segue to screen #2
            guard let screen2VC = storyboard?.instantiateViewController(identifier: "Screen2") as? BookListViewController else {
                return
            }
            
            // pass username to screen 2
            screen2VC.loggedInUser = loggedInUser
            show(screen2VC, sender:self)
            
        }else{
            self.lblErrorMsg.text = "Please enter a valid credentials"
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getAllUser()
        
    }
    
    private func validateUser(givenUsername:String, givenPassword:String) -> Bool {
        
        var isFound:Bool = false;

        for user in users{
            
            if(givenUsername == user.username){
                
                if(givenPassword == user.password){
                    
                    loggedInUser = givenUsername
                    isFound = true
            
                }
            }
        }
        
        return isFound

    }
    
    private func getAllUser() {
        
        db.collection("users").getDocuments {
            (queryResults, error)
            in
                        
            // error checking
            if let err = error {
                print("Error getting documents from the collection")
                print(err)
                return
            }
            
            // everything works
            if (queryResults!.count == 0) {
                print("No documents found in the collection")
            }
            else {
                
                for document in queryResults!.documents {
                                        
                    do {
                        let userFromFS = try document.data(as: User.self)
                        self.users.append(userFromFS!)
                    }
                    catch{
                        print("Error converting document to User object")
                        print(error)
                    }
                    
                }
                print("Number of users converted: \(self.users.count)")
            }
        }
    }

}

