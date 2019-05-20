//
//  User.swift
//  NotesOnTheGo
//
//  Created by admin on 17/05/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import RealmSwift


//un modelo de datos para realm tiene que heredar de object
//todas las variables de un objeto de modelo de datos tiene que llevar el atributo dynamic.
class User: Object{
    @objc dynamic var name : String = ""
    @objc dynamic var surName : String = ""
    @objc dynamic var age : Int = 0
    @objc dynamic var wallet : Float = 0.0
    
}
