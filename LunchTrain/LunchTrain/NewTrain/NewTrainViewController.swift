//
//  NewTrainViewController.swift
//  LunchTrain
//
//  Created by Niamh Power on 21/03/2018.
//  Copyright © 2018 npower. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

class NewTrainViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var createTrainButton: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var placeField: UITextField!
    @IBOutlet weak var titleField: UITextField!

    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> NewTrainViewController {
        let controller = storyboard.instantiateViewController(withIdentifier: "NewTrainViewController") as! NewTrainViewController
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true

        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.addPressed))
        createTrainButton.addGestureRecognizer(gesture)

    }

    @objc func addPressed() {
        createTrainButton.isHidden = true
        activityIndicator.tintColor = .black
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        let user = Auth.auth().currentUser

        guard let place = placeField.text, let title = titleField.text else { return }

        let newTrain = Train(owner: user?.displayName ?? "", place: place, time: datePicker.date, title: title)

        let firestore = Firestore.firestore()

        let trainCollection = firestore.collection("trains")
        let newTrainReference = trainCollection.document()

        firestore.runTransaction({ (transaction, errorPointer) -> Any? in
            transaction.setData(newTrain.dictionary, forDocument: newTrainReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print(error)
            }
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.dismiss(animated: true, completion: nil)
        }
    }
}
