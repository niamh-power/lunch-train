//
//  TrainDetailViewController.swift
//  LunchTrain
//
//  Created by Niamh Power on 21/03/2018.
//  Copyright © 2018 npower. All rights reserved.
//

import UIKit

class TrainDetailViewController: UIViewController {
    var train: Train?
    var trainReference: DocumentReference?

    var localCollection: LocalCollection<Train>!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white

        let query = trainReference!.collection("trains")
        localCollection = LocalCollection(query: query) { [unowned self] (changes) in
            var indexPaths: [IndexPath] = []

            // Only care about additions in this block, updating existing reviews probably not important
            // as there's no way to edit reviews.
            for addition in changes.filter({ $0.type == .added }) {
                let index = self.localCollection.index(of: addition.document)!
                let indexPath = IndexPath(row: index, section: 0)
                indexPaths.append(indexPath)
            }
            self.tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    deinit {
        localCollection.stopListening()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localCollection.listen()
        //titleView.populate(restaurant: restaurant!)
//        if let url = titleImageURL {
//            titleView.populateImage(url: url)
//        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        set {}
        get {
            return .lightContent
        }
    }

//    @IBAction func didTapAddButton(_ sender: Any) {
//        let controller = NewReviewViewController.fromStoryboard()
//        controller.delegate = self
//        self.navigationController?.pushViewController(controller, animated: true)
//    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localCollection.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell",
                                                 for: indexPath) as! ReviewTableViewCell
        let review = localCollection[indexPath.row]
        cell.populate(review: review)
        return cell
    }

    // MARK: - NewReviewViewControllerDelegate
    func reviewController(_ controller: NewReviewViewController, didSubmitFormWithReview review: Review) {
        guard let reference = restaurantReference else { return }
        let reviewsCollection = reference.collection("ratings")
        let newReviewReference = reviewsCollection.document()

        // Writing data in a transaction
        let firestore = Firestore.firestore()
        firestore.runTransaction({ (transaction, errorPointer) -> Any? in

            // Read data from Firestore inside the transaction, so we don't accidentally
            // update using staled client data. Error if we're unable to read here.
            let restaurantSnapshot: DocumentSnapshot
            do {
                try restaurantSnapshot = transaction.getDocument(reference)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            // Error if the restaurant data in Firestore has somehow changed or is malformed.
            guard let restaurant = restaurantSnapshot.data().flatMap(Restaurant.init(dictionary:)) else {
                let error = NSError(domain: "FriendlyEatsErrorDomain", code: 0, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to write to restaurant at Firestore path: \(reference.path)"
                    ])
                errorPointer?.pointee = error
                return nil
            }

            // Update the restaurant's rating and rating count and post the new review at the
            // same time.
            let newAverage = (Float(restaurant.ratingCount) * restaurant.averageRating + Float(review.rating))
                / Float(restaurant.ratingCount + 1)

            transaction.setData(review.dictionary, forDocument: newReviewReference)
            transaction.updateData([
                "numRatings": restaurant.ratingCount + 1,
                "avgRating": newAverage
                ], forDocument: reference)
            return nil
        }) { (object, error) in
            if let error = error {
                print(error)
            } else {
                // Pop the review controller on success
                if self.navigationController?.topViewController?.isKind(of: NewReviewViewController.self) ?? false {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }

    }

}

class RestaurantTitleView: UIView {

    @IBOutlet var nameLabel: UILabel!

    @IBOutlet var categoryLabel: UILabel!

    @IBOutlet var cityLabel: UILabel!

    @IBOutlet var priceLabel: UILabel!

    @IBOutlet var starsView: ImmutableStarsView! {
        didSet {
            starsView.highlightedColor = UIColor.white.cgColor
        }
    }

    @IBOutlet var titleImageView: UIImageView! {
        didSet {
            let gradient = CAGradientLayer()
            gradient.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor, UIColor.clear.cgColor]
            gradient.locations = [0.0, 1.0]

            gradient.startPoint = CGPoint(x: 0, y: 1)
            gradient.endPoint = CGPoint(x: 0, y: 0)
            gradient.frame = CGRect(x: 0,
                                    y: 0,
                                    width: UIScreen.main.bounds.width,
                                    height: titleImageView.bounds.height)

            titleImageView.layer.insertSublayer(gradient, at: 0)
            titleImageView.contentMode = .scaleAspectFill
            titleImageView.clipsToBounds = true
        }
    }

    func populateImage(url: URL) {
        titleImageView.sd_setImage(with: url)
    }

    func populate(train: Train) {
        nameLabel.text = restaurant.name
        starsView.rating = Int(restaurant.averageRating.rounded())
        categoryLabel.text = restaurant.category
        cityLabel.text = restaurant.city
        priceLabel.text = priceString(from: restaurant.price)
    }
}
