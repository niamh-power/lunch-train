

import UIKit
import FirebaseFirestore
import FirebaseAuth

class TrainDetailViewController: ViewController<TrainDetailViewModel> {

    @IBOutlet weak var trainIcon: UIImageView!
    @IBOutlet weak var joinTrainButtonView: UIView!
    @IBOutlet weak var passengersTableView: UITableView!
    @IBOutlet weak var organiserLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var joinTrainLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private let tableViewAdapter = TableViewAdapter<User>()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        viewModel.ready()
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

    private func bindViewModel() {
        viewModel.didChangeData = { [weak self] data in
            guard let strongSelf = self else { return }
            if data.isUserAPassenger {
                strongSelf.disableButton()
            }

            let train = data.train
            strongSelf.organiserLabel.text = "Organiser: \(train.owner)"
            strongSelf.titleLabel.text = train.title
            strongSelf.tableViewAdapter.update(with: data.passengers)
            strongSelf.passengersTableView.reloadData()
        }

        passengersTableView.dataSource = tableViewAdapter
        passengersTableView.delegate = tableViewAdapter
        activityIndicator.isHidden = true

        tableViewAdapter.cellFactory = { (tableView, indexPath, cellData) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
            cell.textLabel?.text = cellData.name
            return cell
        }

        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.joinPressed))
        joinTrainButtonView.addGestureRecognizer(gesture)

        viewModel.joinTrainRequestCompleted = { [weak self] success in
            guard let strongSelf = self else { return }
            strongSelf.activityIndicator.isHidden = true
            strongSelf.joinTrainLabel.isHidden = false
        }
    }

    private func disableButton() {
        joinTrainButtonView.backgroundColor = UIColor.gray
        joinTrainButtonView.isUserInteractionEnabled = false
    }

    @objc func joinPressed(sender: UITapGestureRecognizer) {
        viewModel.joinTrain()
        activityIndicator.isHidden = false
        joinTrainLabel.isHidden = true
    }
}
