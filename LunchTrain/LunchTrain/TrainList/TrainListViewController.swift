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

        // Blue bar with white color
        navigationController?.navigationBar.barTintColor =
            UIColor(red: 0x3d/0xff, green: 0x5a/0xff, blue: 0xfe/0xff, alpha: 1.0)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes =
            [ NSAttributedStringKey.foregroundColor: UIColor.white ]

        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 200
        query = baseQuery()

        self.navigationController?.navigationBar.barStyle = .black
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        observeQuery()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObserving()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        set {}
        get {
            return .lightContent
        }
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
//        let controller = RestaurantDetailViewController.fromStoryboard()
//        controller.titleImageURL = restaurants[indexPath.row].photo
//        controller.restaurant = restaurants[indexPath.row]
//        controller.restaurantReference = documents[indexPath.row].reference
//        self.navigationController?.pushViewController(controller, animated: true)
    }
}

class TrainTableViewCell: UITableViewCell {

    @IBOutlet weak var passengersLabel: UILabel!
    @IBOutlet weak var organiserLabel: UILabel!
    @IBOutlet weak var trainIcon: UIImageView!
    @IBOutlet weak var trainTitleLabel: UILabel!

    func populate(train: Train) {
        organiserLabel.text = train.owner
        trainTitleLabel.text = train.title
    }
}
