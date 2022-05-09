//
//  BookListViewController.swift
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class BookListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let db = Firestore.firestore()
    
    var books:[Book] = []
    
    var loggedInUser = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lblError: UILabel!


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        // get the current book
        let currBook = self.books[indexPath.row]
        
        cell.textLabel?.text = currBook.title + " by " + currBook.author
        
        if(currBook.isAvailable){
            cell.detailTextLabel?.text = "Available"
        }else{
            cell.detailTextLabel?.text = "Borrowed by: \(currBook.borrowedBy!)"
        }

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // get the current book
        var currBook = self.books[indexPath.row]
        
        if(currBook.isAvailable){
            // clear error
            lblError.text = ""
            
            // add the username to current book
            currBook.borrowedBy = loggedInUser
            
            do {
                try db.collection("books").document(books[indexPath.row].id!).setData(from: currBook)

                // book updated successfully in FB
                // update array
                books[indexPath.row].borrowedBy = loggedInUser
                
                // update ui
                self.tableView.reloadData()
                
            }
            catch{
                print("Error when updating book in FS")
                print(error)
            }

        }else{
            if(currBook.borrowedBy == loggedInUser){
                lblError.text = "You already borrowed this book"
            }else{
                lblError.text = "The book is not available to borrow"
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // get the current book
            var currBook = self.books[indexPath.row]
            
            if(currBook.isAvailable){
                
                // Book is available, so noone can return
                lblError.text = "The book is available"

            }else{
                if(currBook.borrowedBy != loggedInUser){
                    
                    // Book is borrowed by someone else
                    lblError.text = "You cannot return this book"
                    
                }else{
                    // User can return book
                    
                    // update the book info
                    currBook.borrowedBy = nil
                    
                    do {
                        try db.collection("books").document(books[indexPath.row].id!).setData(from: currBook)

                        // book updated successfully in FB
                        // update array
                        books[indexPath.row].borrowedBy = nil
                        
                        // update ui
                        self.tableView.reloadData()
                        
                    }
                    catch{
                        print("Error when updating book in FS")
                        print(error)
                    }
                    
                }
            }
            
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        db.collection("books").getDocuments {
            (queryResults, error) in
            
            if let err = error {
                print("Error retrieving documents from FS")
                print(err)
            }
            else {
                for document in queryResults!.documents {
                    do {
                        let bookFromFS = try document.data(as: Book.self)
                        self.books.append(bookFromFS!)
                    }
                    catch{
                        print("Error converting document to Book object")
                        print(error)
                    }
                }
                print("Number of books converted: \(self.books.count)")
                self.tableView.reloadData()
            }
        }

    }

}
