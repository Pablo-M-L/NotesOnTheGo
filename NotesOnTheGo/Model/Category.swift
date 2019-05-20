//
//  Category.swift
//  NotesOnTheGo
//
//  Created by admin on 15/05/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

//para realm
class Category: Object{
    //propiedades del modelo core data que vamos a migrar
    @objc dynamic var colorHex : String?
    @objc dynamic var image : Data?
    @objc dynamic var title : String = ""
    
    //relacion de uno a muchos. one to many
    //esto obliga a tener un linking Objects en la clase Note.
    let notes = List<Note>()
    
}


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
