//
//  TrainService.swift
//  LunchTrain
//
//  Created by Niamh Power on 22/09/2018.
//  Copyright © 2018 npower. All rights reserved.
//

import Foundation
import FirebaseFirestore
import CodableFirebase
import FirebaseAuth

struct User: Codable {
    var userId: String?
    var userName: String
    var deviceToken: String? = ""
}

class TrainService {
    func saveNewUser(deviceToken: String?, callback: ((_ success: Bool) -> Void)?) {
        let userName = getCurrentUserName()
        let userId = Auth.auth().currentUser?.uid
        let newUser = try! FirestoreEncoder().encode(User(userId: userId, userName: userName, deviceToken: deviceToken))
        
        let firestore = Firestore.firestore()
        let userCollection = firestore.collection("users")
        
        let newUserReference = userCollection.document()
        
        firestore.runTransaction( { (transaction, errorPointer) -> Any in
            transaction.setData(newUser, forDocument: newUserReference)
        }) { (object, error) in
            if error != nil {
                callback?(false)
                return
            }
            
            callback?(true)
        }
    }
    
    func saveNewTrain(name: String, time: Date, place: String, callback: @escaping ((_ success: Bool) -> Void)) {
        let newTrain = try! FirestoreEncoder().encode(Train(ownerId: (Auth.auth().currentUser?.uid)!, place: place, time: time, title: name))
        
        let firestore = Firestore.firestore()
        let trainCollection = firestore.collection("trains")
        
        let newTrainReference = trainCollection.document()
        
        firestore.runTransaction( { (transaction, errorPointer) -> Any in
            transaction.setData(newTrain, forDocument: newTrainReference)
        }) { (object, error) in
            if let error = error {
                print(error)
                callback(false)
                return
            }
            
            callback(true)
        }
    }
    
    private func getCurrentUserName() -> String {
        let user = Auth.auth().currentUser
        return user?.displayName ?? ""
    }
}
