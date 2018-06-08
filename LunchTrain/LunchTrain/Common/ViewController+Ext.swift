//
//  ViewController+Ext.swift
//  LunchTrain
//
//  Created by Niamh Power on 08/06/2018.
//  Copyright © 2018 npower. All rights reserved.
//

import Foundation
import UIKit

public class ViewController<T>: UIViewController {
    var viewModel: T!

    override public func viewDidLoad() {
        super.viewDidLoad()
        assertViewModel()
    }
}

private extension ViewController {
    func assertViewModel() {
        assert(viewModel != nil)
    }
}
