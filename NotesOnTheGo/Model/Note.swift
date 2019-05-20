//
//  Note.swift
//  NotesOnTheGo
//
//  Created by admin on 17/05/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import RealmSwift

class Note: Object{
    @objc dynamic var title : String = ""
    @objc dynamic var checked : Bool = false
    @objc dynamic var dateCreation : Date?
    
    //relacion inversa de los hijos con el padre.
    //LinkingObjects es un contenedor para autoActualizar las relaciones, se le pasa el tipo de dato con Category
    //y la propiedad de la que procede la relacion inversa.
    var parentCategory = LinkingObjects(fromType: Category.self, property: "notes")
    
}
