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
    var userName: String
    var deviceToken: String
}

class TrainService {
    func saveNewUser(deviceToken: String, callback: @escaping ((_ success: Bool) -> Void)) {
        let userName = getCurrentUserName()
        let newUser = try! FirestoreEncoder().encode(User(userName: userName, deviceToken: deviceToken))
        
        let firestore = Firestore.firestore()
        let userCollection = firestore.collection("users")
        
        let newUserReference = userCollection.document()
        
        firestore.runTransaction( { (transaction, errorPointer) -> Any in
            transaction.setData(newUser, forDocument: newUserReference)
        }) { [weak self] (object, error) in
            if let error = error {
                callback(false)
                return
            }
            
            callback(true)
        }
    }
    
    func saveNewTrain(name: String, time: Date, place: String) {
        let userName = getCurrentUserName()
        let newTrain = Train(owner: userName, place: place, time: time, title: name)
        
        let firestore = Firestore.firestore()
        let trainCollection = firestore.collection("trains")
        
        let newTrainReference = trainCollection.document()
        
        firestore.runTransaction( { (transaction, errorPointer) -> Any in
            transaction.setData(newTrain.dictionary, forDocument: newTrainReference)
        }) { [weak self] (object, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error)
                //strongSelf.newTrainRequestCompleted?(false)
                return
            }
            
            //strongSelf.newTrainRequestCompleted?(true)
        }
    }
    
    private func getCurrentUserName() -> String {
        let user = Auth.auth().currentUser
        return user?.displayName ?? ""
    }
}
