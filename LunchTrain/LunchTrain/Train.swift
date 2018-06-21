//
//  Train.swift
//  LunchTrain
//
//  Created by Niamh Power on 21/03/2018.
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



struct Person {
    var name: String
    var userId: String

    var dictionary: [String: Any] {
        return [
            "name": name,
            "user_id": userId
        ]
    }
}

extension Person: DocumentSerializable {

    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
        let userId = dictionary["user_id"] as? String
            else { return nil }

        self.init(name: name, userId: userId)
    }
}
