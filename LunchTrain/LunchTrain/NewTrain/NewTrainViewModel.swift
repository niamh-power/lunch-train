//
//  NewTrainViewModel.swift
//  LunchTrain
//
//  Created by Niamh Power on 08/06/2018.
//  Copyright © 2018 npower. All rights reserved.
//

import FirebaseFirestore
import FirebaseAuth
import CodableFirebase

class NewTrainViewModel {

    var newTrainRequestCompleted: ((_ success: Bool) -> Void)?

    func saveNewTrain(name: String, time: Date, place: String) {
        let newTrain = try! FirestoreEncoder().encode(Train(ownerId: (Auth.auth().currentUser?.uid)!, place: place, time: time, title: name))

        let firestore = Firestore.firestore()
        let trainCollection = firestore.collection("trains")

        let newTrainReference = trainCollection.document()

        firestore.runTransaction( { (transaction, errorPointer) -> Any in
            transaction.setData(newTrain, forDocument: newTrainReference)
        }) { [weak self] (object, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error)
                strongSelf.newTrainRequestCompleted?(false)
                return
            }

            strongSelf.newTrainRequestCompleted?(true)
        }
    }

    private func getCurrentUserName() -> String {
        let user = Auth.auth().currentUser
        return user?.displayName ?? ""
    }
}
