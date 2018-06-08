//
//  TrainListViewData.swift
//  LunchTrain
//
//  Created by Niamh Power on 08/06/2018.
//  Copyright © 2018 npower. All rights reserved.
//

import Foundation

struct Train {
    var owner: String
    var place: String
    var time: Date
    var title: String

    var dictionary: [String: Any] {
        return [
            "owner": owner,
            "place": place,
            "time": time,
            "title": title
        ]
    }
}

extension Train: DocumentSerializable {

    init?(dictionary: [String : Any]) {
        guard let owner = dictionary["owner"] as? String,
            let place = dictionary["place"] as? String,
            let time = dictionary["time"] as? Date,
            let title = dictionary["title"] as? String
            else { return nil }

        self.init(owner: owner, place: place, time: time, title: title)
    }
}


struct TrainListViewData {
    var trains: [Train]
}
