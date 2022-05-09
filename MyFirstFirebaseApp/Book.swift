//
//  Book.swift
//

import Foundation
import FirebaseFirestoreSwift

struct Book:Codable {

    @DocumentID var id:String?
    
    var title:String = ""
    var author:String = ""
    var borrowedBy:String?
    
    var isAvailable:Bool {
        get{
            var availability:Bool
            if(borrowedBy == nil){
                availability = true
            }else {
                availability = false
            }
            return availability
        }
    }
    
}
