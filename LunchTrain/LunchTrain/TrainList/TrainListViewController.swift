//
//  TrainListViewController.swift
//  LunchTrain
//
//  Created by Niamh Power on 21/03/2018.
//  Copyright © 2018 npower. All rights reserved.
//

import UIKit
import FirebaseFirestore
import SnapKit

class TrainListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    private var trains: [Train] = []
    private var documents: [DocumentSnapshot] = []
    private var selectedTrain: Train?

    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery()
            }
        }
    }

    private var listener: ListenerRegistration?

    fileprivate func observeQuery() {
        guard let query = query else { return }
        stopObserving()

        // Display data from Firestore, part one

        listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            let models = snapshot.documents.map { (document) -> Train in
                if let model = Train(dictionary: document.data()) {
                    return model
                } else {
                    // Don't use fatalError here in a real app.
                    fatalError("Unable to initialize type \(Train.self) with dictionary \(document.data())")
                }
            }
            self.trains = models
            self.documents = snapshot.documents

            self.tableView.reloadData()
        }
    }

    fileprivate func stopObserving() {
        listener?.remove()
    }

    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("trains").limit(to: 50)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 200
        query = baseQuery()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeQuery()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObserving()
    }

    deinit {
        listener?.remove()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TrainTableViewCell
        let train = trains[indexPath.row]
        cell.populate(train: train)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trains.count
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedTrain = trains[indexPath.row]

        let vc = TrainDetailViewController.fromStoryboard()
        vc.train = selectedTrain
        vc.trainReference = documents[indexPath.row].reference

        navigationController?.pushViewController(vc, animated: true)
    }

}

class TrainTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var organiserLabel: UILabel!
    @IBOutlet weak var trainIcon: UIImageView!
    @IBOutlet weak var trainTitleLabel: UILabel!

    func populate(train: Train) {
        organiserLabel.text = train.owner
        trainTitleLabel.text = train.title

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short

        timeLabel.text = dateFormatter.string(from: train.time)
    }
}
