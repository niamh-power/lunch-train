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

class TrainListViewController: ViewController<TrainListViewModel>, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    private var selectedTrain: Train?
    @IBOutlet weak var createTrainButton: UIView!

    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.didChangeData = { [weak self] data in
            guard let strongSelf = self else { return }
            strongSelf.tableView.reloadData()
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 200

        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.addPressed))
        createTrainButton.addGestureRecognizer(gesture)
    }

    @objc func addPressed(sender:UITapGestureRecognizer){
        let controller = NewTrainViewController.fromStoryboard()
        self.navigationController?.present(controller, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.observeQuery()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopObserving()
    }

    deinit {
        listener?.remove()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TrainTableViewCell
        let train = viewModel.viewData.trains[indexPath.row]
        cell.populate(train: train)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.viewData.trains.count
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedTrain = viewModel.viewData.trains[indexPath.row]

        let vc = TrainDetailViewController.fromStoryboard()
        vc.train = selectedTrain
        vc.trainReference = viewModel.documents[indexPath.row].reference

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
