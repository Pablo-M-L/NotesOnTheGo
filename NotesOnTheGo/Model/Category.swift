//
//  Category.swift
//  NotesOnTheGo
//
//  Created by admin on 15/05/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import Foundation


extension Category{
    var color: UIColor? {
        get{
            guard let hex = colorHex else {return nil}
            return UIColor(hex: hex)
        }
        set(newColor){
            if let newColor = newColor {
                colorHex = newColor.toHex
            }
        }
    }
}
