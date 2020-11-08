//
//  Constants.swift
//  Project
//
//  Created by Mostak Khan W1622449 on 22/06/2019.
//  Copyright © 2019 Swift. All rights reserved.
//

import UIKit
import UserNotifications

//Date formatter

public let calendar = Calendar.current

public let formateDate = { () -> DateFormatter in 
    let date = DateFormatter()
    date.locale = Locale.current
    date.dateFormat = "dd MMMM yyyy"
    return date
}()

//notification

public let reloadMasterNotificationKey = "reloadMasterNotificationKey"

public var modifyVC: Bool = true

public var previousProjectID: Int? = UserDefaults.standard.integer(forKey: "lastSeenProjectID")

public let dateComponents = DateComponents()

public let showContext = (UIApplication.shared.delegate as! AppDelegate).perContainer.viewContext

public let notificationShown = UNUserNotificationCenter.current()
