//
//  TrainDetailViewModel.swift
//  LunchTrain
//
//  Created by Niamh Power on 09/06/2018.
//  Copyright © 2018 npower. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class TrainDetailViewModel {
    var didChangeData: ((TrainDetailViewData) -> Void)?
    var trainReference: DocumentReference?
    var localCollection: LocalCollection<User>!
    var joinTrainRequestCompleted: ((_ success: Bool) -> Void)?

    fileprivate var query: CollectionReference? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery()
            }
        }
    }

    private var listener: ListenerRegistration?
    var documents: [DocumentSnapshot] = []

    var viewData: TrainDetailViewData {
        didSet {
            didChangeData?(viewData)
        }
    }

    init(viewData: TrainDetailViewData) {
        self.viewData = viewData
        self.trainReference = viewData.trainReference
        query = baseQuery()
    }

    func ready() {
        didChangeData?(viewData)
    }

    func observeQuery() {
        guard let query = query else { return }
        stopObserving()

        listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }

            let models = snapshot.documents.compactMap { (document) -> User? in
                if let model = User(dictionary: document.data()) {
                    return model
                } else {
                    print("error parsing document: \(document.data())")
                    return nil
                }
            }

            self.viewData.passengers = models
            self.checkIfUserIsAPassenger()
            self.documents = snapshot.documents
        }
    }

    func stopObserving() {
        listener?.remove()
    }

    fileprivate func baseQuery() -> CollectionReference? {
        return trainReference?.collection("passengers")
    }

    func joinTrain() {
        guard let query = query else { return }

        let user = Auth.auth().currentUser
        let name = user?.displayName ?? ""

        let passenger = User(name: name)

        let newPassengerReference = query.document()

        Firestore.firestore().runTransaction( { (transaction, errorPointer) -> Any in
            transaction.setData(passenger.dictionary, forDocument: newPassengerReference)
        }) { [weak self] (object, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error)
                strongSelf.joinTrainRequestCompleted?(false)
                return
            }

            strongSelf.joinTrainRequestCompleted?(true)
        }
    }

    private func checkIfUserIsAPassenger() {
        viewData.isUserAPassenger = viewData.passengers.contains(User(name: getCurrentUserName()))
    }

    private func getCurrentUserName() -> String {
        let user = Auth.auth().currentUser
        return user?.displayName ?? ""
    }
}
