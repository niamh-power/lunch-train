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
