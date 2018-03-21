

import UIKit
import FirebaseFirestore
import FirebaseAuth

class TrainDetailViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var trainIcon: UIImageView!
    @IBOutlet weak var joinTrainButtonView: UIView!
    @IBOutlet weak var passengersTableView: UITableView!
    @IBOutlet weak var organiserLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    var train: Train?
    var trainReference: DocumentReference?
    var localCollection: LocalCollection<Person>!

    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> TrainDetailViewController {
        let controller = storyboard.instantiateViewController(withIdentifier: "TrainDetailViewController") as! TrainDetailViewController
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        passengersTableView.dataSource = self
        passengersTableView.rowHeight = UITableViewAutomaticDimension
        passengersTableView.estimatedRowHeight = 140

        let query = trainReference!.collection("passengers")
        localCollection = LocalCollection(query: query) { [unowned self] (changes) in
            var indexPaths: [IndexPath] = []

            for addition in changes.filter({ $0.type == .added }) {
                let index = self.localCollection.index(of: addition.document)!
                let indexPath = IndexPath(row: index, section: 0)
                indexPaths.append(indexPath)
            }

            self.passengersTableView.insertRows(at: indexPaths, with: .automatic)
        }


        organiserLabel.text = "Organiser: \(train?.owner ?? "")"
        titleLabel.text = train?.title ?? "\(train?.owner ?? "User")'s train"

        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.joinPressed))
        joinTrainButtonView.addGestureRecognizer(gesture)

    }

    deinit {
        localCollection.stopListening()
    }

    @objc func joinPressed(sender:UITapGestureRecognizer){
        let user = Auth.auth().currentUser
        let person = Person(name: (user?.displayName)!, userId: (user?.uid)!)

        joinTrain(with: person)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localCollection.listen()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localCollection.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let person = localCollection[indexPath.row]
        cell?.textLabel?.text = person.name
        return cell!
    }

    func joinTrain(with person: Person) {
        guard let reference = trainReference else { return }
        let passengersCollection = reference.collection("passengers")
        let newPassengerReference = passengersCollection.document()

        let firestore = Firestore.firestore()
        firestore.runTransaction({ (transaction, errorPointer) -> Any? in
            transaction.setData(person.dictionary, forDocument: newPassengerReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print(error)
            }
        }
    }
}
