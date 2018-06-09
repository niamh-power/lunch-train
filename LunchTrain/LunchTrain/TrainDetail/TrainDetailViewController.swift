

import UIKit
import FirebaseFirestore
import FirebaseAuth

class TrainDetailViewController: ViewController<TrainDetailViewModel> {

    @IBOutlet weak var trainIcon: UIImageView!
    @IBOutlet weak var joinTrainButtonView: UIView!
    @IBOutlet weak var passengersTableView: UITableView!
    @IBOutlet weak var organiserLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel.didChangeData = { [weak self] data in
            guard let strongSelf = self else { return }
            let train = data.train
            strongSelf.organiserLabel.text = "Organiser: \(train.owner)"
            strongSelf.titleLabel.text = train.title
        }
    }
}
