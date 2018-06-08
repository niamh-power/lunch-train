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

    private var viewModel = NewTrainViewModel()

    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> NewTrainViewController {
        let controller = storyboard.instantiateViewController(withIdentifier: "NewTrainViewController") as! NewTrainViewController
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true

        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.addPressed))
        createTrainButton.addGestureRecognizer(gesture)

        viewModel.newTrainRequestCompleted = { [weak self] success in
            guard let strongSelf = self else { return }
            strongSelf.activityIndicator.stopAnimating()
            strongSelf.activityIndicator.isHidden = true
            strongSelf.dismiss(animated: true, completion: nil)
        }
    }

    @objc func addPressed() {
        createTrainButton.isHidden = true
        activityIndicator.tintColor = .black
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        viewModel.saveNewTrain(name: titleField.text ?? "", time: datePicker.date, place: placeField.text ?? "")
    }
}
