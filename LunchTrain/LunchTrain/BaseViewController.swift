//
//  ViewController.swift
//  LunchTrain
//
//  Created by Niamh Power on 21/03/2018.
//  Copyright © 2018 npower. All rights reserved.
//

import UIKit
import FirebaseUI

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
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        let deviceToken = UserDefaults.standard.string(forKey: Keys.deviceToken.rawValue)
        // check that the user doesn't already exist!
        TrainService().saveNewUser(deviceToken: deviceToken, callback: nil)
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

