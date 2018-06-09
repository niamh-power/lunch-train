//
//  TrainDetailViewModel.swift
//  LunchTrain
//
//  Created by Niamh Power on 09/06/2018.
//  Copyright © 2018 npower. All rights reserved.
//

import Foundation

class TrainDetailViewModel {
    var didChangeData: ((TrainDetailViewData) -> Void)?

    var viewData: TrainDetailViewData {
        didSet {
            didChangeData?(viewData)
        }
    }

    init(viewData: TrainDetailViewData) {
        self.viewData = viewData
    }
}
