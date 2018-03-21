//
//  Train.swift
//  LunchTrain
//
//  Created by Niamh Power on 21/03/2018.
//  Copyright © 2018 npower. All rights reserved.
//

import Foundation

struct Person {
    var name: String
}

struct Train {
    var owner: String
    var place: String
    var time: Date
    var passengers: [String]

    var dictionary: [String: Any] {
        return [
            "owner": owner,
            "place": place,
            "time": time,
            "passengers": passengers
        ]
    }

}

extension Train: DocumentSerializable {

    init?(dictionary: [String : Any]) {
        guard let owner = dictionary["owner"] as? String,
            let place = dictionary["place"] as? String,
            let time = dictionary["time"] as? Date
            else { return nil }

        self.init(owner: owner, place: place, time: time, passengers: [])
    }
}

