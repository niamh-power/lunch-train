

import UIKit

class TrainDetailViewController: UIViewController {

    @IBOutlet weak var trainIcon: UIImageView!
    @IBOutlet weak var joinTrainButtonView: UIView!
    @IBOutlet weak var passengersTableView: UITableView!
    @IBOutlet weak var organiserLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    var train: Train?

    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> TrainDetailViewController {
        let controller = storyboard.instantiateViewController(withIdentifier: "TrainDetailViewController") as! TrainDetailViewController
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        organiserLabel.text = "Organiser: \(train?.owner ?? "")"
    }
}
