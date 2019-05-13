//
//  NotesTableViewController.swift
//  NotesOnTheGo
//
//  Created by admin on 09/05/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class NotesTableViewController: UITableViewController {

    //var notesArray  = [String]()
    var notesArray  = [Note]()

    //como no se puede guardar objetos que no sean propios del sistema en un userDefaults,
    // vamos a crear un archivo plis (property List) propio en la carpeta documents de la aplicacion.
    
    //obtiene la ruta de la carpeta documents de la aplicacion.
    // se le pasa como argumento .documentDirectory para indicar en que carpeta queremos buscar. (cada app tiene las carpetas de descargas, documentos...)
    // y userDomainMask para guardar la informacion en el sistema de carpetas del usuario del dispositivo.
    //devuelve un array de rutas posibles del que se coge el primer item, con first.
    //añadimos una referencia a un archivo en la carpeta con appendigPath....
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Notes.plist")
    
    //let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //recupera los datos de tipo string guardados en el plist, como preferencias de usuario.
        /*if let previousNotes = defaults.array(forKey: "NotesArray") as? [String]{
            self.notesArray = previousNotes
        }*/
        
        loadNotes()
        
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        // cell.textLabel?.text = notesArray[indexPath.row]
        
        let note = notesArray[indexPath.row]
        
        cell.textLabel?.text = note.title
        
        //comprueba si el checked tiene que estar marcado.
        if note.checked{
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }

        return cell
    }
    

    // MARK: - metodos del delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notesArray[indexPath.row]
        
        // al pulsar en el checkbox cambia el esado de este. esta propiedad tambien esta en el editor grafico de xcode.
        
        //opcion 1
        /*
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark{
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            note.checked = false
        }else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            note.checked = true
        }*/
        
        //opcion 2:
        //note.checked = !note.checked
        //tableView.cellForRow(at: indexPath)?.accessoryType = (note.checked ? .checkmark : .none)
        
        //opcion 3:
        note.checked = (note.checked ? false : true)
        
        persistNotes()
        
        tableView.cellForRow(at: indexPath)?.accessoryType = (note.checked ? .checkmark : .none)
        
        //funcion que evita que la celda se quede de color gris al seleccionarla.
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: añadir nuevos item a la tabla.
    
    @IBAction func addNewNote(_ sender: UIBarButtonItem) {
        
        let note = Note()
        
        var textField = UITextField()
        
        let alerta = UIAlertController(title: "Añadir nueva nota", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Añade un item", style: .default) { (action) in
            
            // guarda los datos en el plist de user preferends
            /*self.notesArray.append(textField.text!)
            
            //guarda el array completo asociado a una clave en la variable defaults para la persistencia de datos.
            self.defaults.set(self.notesArray, forKey:  "NotesArray")
            */
            
            note.title = textField.text!
            self.notesArray.append(note)
            //guarda el array completo asociado a una clave en la variable defaults para la persistencia de datos.
            //self.defaults.set(self.notesArray, forKey:  "NotesArray")
            
            self.persistNotes()
        }
        let cancelAction = UIAlertAction(title: "cancelar", style: .cancel, handler: nil)
        
        alerta.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "introduce aqui tu nota"
            textField = alertTextfield
            
        }
        
        
        alerta.addAction(addAction)
        alerta.addAction(cancelAction)
        
        present(alerta,animated: true, completion: nil)
        
    }
    
    func persistNotes(){
        //añadimos al archivo Notes.plist creado por nosotros.
        let encoder = PropertyListEncoder()
        
        do{
            let data = try encoder.encode(self.notesArray)
            try data.write(to: self.dataFilePath!)
        }catch{
            print("error al codificar o guardar el array \(error)")
        }
        
        //recarga la pantalla.
        self.tableView.reloadData()
    }
    
    func loadNotes(){
        //intenta obtener los datos del fichero.
        if let data = try? Data(contentsOf: dataFilePath!){
            //descodificador de property list
            let decoder = PropertyListDecoder()
            do{
                //al decoder hay que indicarle el tipo de dato que tiene que decodificar, en este caso es
                //un array de tipo Note. y se pone .self para indicar que se trata de dicha clase.
                notesArray = try decoder.decode([Note].self, from: data)
            }catch{
                print("error al decodificar o leer el array \(error)")
            }
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
