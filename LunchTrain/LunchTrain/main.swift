//
//  main.swift
//  LunchTrain
//
//  Created by Niamh Power on 08/06/2018.
//  Copyright © 2018 npower. All rights reserved.
//

import Foundation

import UIKit

// reference each view controller before UIApplicationMain runs
print(TrainListViewController.self)

// The following is required because there's an impedence mismatch between
// `CommandLine` and `UIApplicationMain` <rdar://problem/25693546>.
let argv = UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(
    to: UnsafeMutablePointer<Int8>.self,
    capacity: Int(CommandLine.argc)
)

UIApplicationMain(CommandLine.argc, argv, nil, NSStringFromClass(AppDelegate.self))
