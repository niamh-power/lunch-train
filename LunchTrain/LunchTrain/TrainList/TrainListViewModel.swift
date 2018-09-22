//
//  TrainListViewModel.swift
//  LunchTrain
//
//  Created by Niamh Power on 08/06/2018.
//  Copyright © 2018 npower. All rights reserved.
//

import Foundation
import FirebaseFirestore
import CodableFirebase

class TrainListViewModel {
    var trainsReference: DocumentReference?

    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery()
            }
        }
    }

    private var listener: ListenerRegistration?
    var documents: [DocumentSnapshot] = []
    var didChangeData: ((TrainListViewData) -> Void)?

    var viewData: TrainListViewData {
        didSet {
            didChangeData?(viewData)
        }
    }

    init(viewData: TrainListViewData) {
        self.viewData = viewData
        query = baseQuery()
    }

    func observeQuery() {
        guard let query = query else { return }
        stopObserving()

        listener = query.addSnapshotListener { [unowned self] (snapshot, error) in

            guard let snapshot = snapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }

            let models = snapshot.documents.compactMap { (document) -> Train? in
                do {
                    let model = try FirestoreDecoder().decode(Train.self, from: document.data())
                    return model
                } catch {
                    print("error parsing document: \(document.data())")
                    return nil
                }
            }
            self.viewData.trains = models
            self.documents = snapshot.documents
        }
    }

    func stopObserving() {
        listener?.remove()
    }

    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("trains").limit(to: 50)
    }
}
