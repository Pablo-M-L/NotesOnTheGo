//
//  Note.swift
//  NotesOnTheGo
//
//  Created by admin on 13/05/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation

//añadimos los protocolos decodabel y encodable para poder usarlo al crear nuestra property list.
//se puede añadir por separado: class Note: Encodable, Decodable{.....
//o se puede añadir los dos juntos con Codable.
class NoteModel: Codable{
    var title = ""
    var checked = false
}
