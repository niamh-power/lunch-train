//
//  ViewController.swift
//  LunchTrain
//
//  Created by Niamh Power on 21/03/2018.
//  Copyright © 2018 npower. All rights reserved.
//

import UIKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class BaseViewController: UIViewController, FUIAuthDelegate {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if Auth.auth().currentUser != nil {
            showList()
        } else {
            let authUI = FUIAuth.defaultAuthUI()
            authUI?.delegate = self
            let providers: [FUIAuthProvider] = [
                FUIGoogleAuth()]

            authUI?.providers = providers

            let authViewController = authUI!.authViewController()
            self.present(authViewController, animated: true, completion: nil)
        }
    }

    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        showList()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard
            let viewController = segue.destination as? TrainListViewController
            else { return }

        viewController.viewModel = TrainListViewModel(viewData: TrainListViewData(trains: []))
    }

    private func showList() {
        performSegue(withIdentifier: "showList", sender: self)
    }
}

