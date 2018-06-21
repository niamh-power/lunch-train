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

class TrainListViewController: ViewController<TrainListViewModel> {

    @IBOutlet weak var tableView: UITableView!
    private var selectedTrain: Train?
    private var selectedTrainReference: DocumentReference?

    @IBOutlet weak var createTrainButton: UIView!
    private let tableViewAdapter = TableViewAdapter<Train>()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.didChangeData = { [weak self] data in
            guard let strongSelf = self else { return }
            strongSelf.tableViewAdapter.update(with: data.trains)
            strongSelf.tableView.reloadData()
        }

        tableView.dataSource = tableViewAdapter
        tableView.delegate = tableViewAdapter
        tableView.estimatedRowHeight = 200
        

        tableViewAdapter.cellFactory = { (tableView, indexPath, cellData) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TrainTableViewCell else { return UITableViewCell() }
            cell.populate(train: cellData)
            return cell
        }

        tableViewAdapter.didSelectItem = { [weak self] rowData, indexPath in
            guard let strongSelf = self else { return }
            strongSelf.tableView.deselectRow(at: indexPath, animated: true)
            strongSelf.selectedTrain = rowData
            strongSelf.selectedTrainReference = strongSelf.viewModel.documents[indexPath.row].reference
            strongSelf.detailPressed()
        }

        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.addPressed))
        createTrainButton.addGestureRecognizer(gesture)
    }

    func detailPressed() {
        performSegue(withIdentifier: "showDetail", sender: self)
    }

    @objc func addPressed(sender:UITapGestureRecognizer){
        performSegue(withIdentifier: "addTrain", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "showDetail" {
            let detailViewModel = TrainDetailViewModel(viewData: TrainDetailViewData(train: selectedTrain!, trainReference: selectedTrainReference!, passengers: [], isUserAPassenger: false))
            let vc = segue.destination as? TrainDetailViewController
            vc?.viewModel = detailViewModel
            return
        }

        guard
            let viewController = segue.destination as? NewTrainViewController
            else { return }

        viewController.viewModel = NewTrainViewModel()
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
        viewModel.stopObserving()
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
