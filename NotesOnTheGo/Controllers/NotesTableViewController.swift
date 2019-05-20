//
//  NotesTableViewController.swift
//  NotesOnTheGo
//
//  Created by admin on 09/05/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class NotesTableViewController: UITableViewController {

    //var notesArray  = [String]()
    //var notesArray  = [NoteModel]()
    var notes : Results<Note>?
    //variable asignada desde la actividad anterior.
    //cuando recibe el valor llama al loadNotes.
    var selectedCategory: Category? {
        didSet{
            loadNotes()
        }
    }

    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = selectedCategory?.title
        //oculta la barra de busqueda al hacer scroll.
        self.navigationItem.hidesSearchBarWhenScrolling = true
        
        loadNotes()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        // cell.textLabel?.text = notesArray[indexPath.row]
        
        let note = notes![indexPath.row]
        
        cell.textLabel?.text = note.title
        cell.backgroundColor = selectedCategory?.color
        
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
        //cambia el valor del checked
        if let note = notes?[indexPath.row]{
            do{
                try realm.write {
                    note.checked = !note.checked
                }
            }catch{
                print("error al guardar cambio del check \(error)")
            }
            //marca o desmarca el checkbox
            tableView.cellForRow(at: indexPath)?.accessoryType = (note.checked ? .checkmark : .none)
            //impide que la celda se quede en gris al pulsarla.
            tableView.deselectRow(at: indexPath, animated: true)
        }
        //borrarNotes(indexRow: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //MARK: añadir nuevos item a la tabla.
    
    @IBAction func addNewNote(_ sender: UIBarButtonItem) {
        
      
        var textField = UITextField()
        
        let alerta = UIAlertController(title: "Añadir nueva nota", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Añade un item", style: .default) { (action) in
            
            do{
                try self.realm.write {
                    let note = Note()
                    note.title = textField.text!
                    note.dateCreation = Date()
                    //añadimos el parent a la nota, en este caso notes es la propiedad de relacion.
                    self.selectedCategory?.notes.append(note)
                    self.tableView.reloadData()
                }
            }
            catch{
                print("error al guardar items \(error)")
            }

            
            
            
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
    
    
    func loadNotes(){
     
        //accede a la propiedad notes del la clase Category que era la que creaba la relacion entre Category y Note.
        notes = selectedCategory?.notes.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()

    }
    
    //borra un item del array.
    func borrarNotes(indexRow: Int){
        if let note = notes?[indexRow]{
            do{
                try self.realm.write {
                    realm.delete(note)
                    //self.tableView.reloadData()
                }
            }
            catch{
                print("error al guardar items \(error)")
            }
        }
        
        // despues se borra del array.
        //notes.remove(at: indexRow)
    }

}

//los delegados se pueden escribir fuera de la clase como una extension, aunque es como si estubieran detro de la clase.
//esto permite organizar mejor el codigo, y que sea mas legible.

extension NotesTableViewController: UISearchBarDelegate{
    
    //metodos de la search bar.
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let searchText = searchBar.text!
        

        //si se pulsa el boton de buscar y el searchText esta en blanco hace una consulta global.
        if searchText == "" {
            // si no hay texto hace una busqueda completa y muestra todos los items.
            loadNotes() }
        else{

            //predicado de busqueda, con formato y argumentos.
            // en este caso busca en cualquier item en el que el title contenga el texto pasado como argumento.
            // %@ significa que esos signos se sustituyen por el argumento que se le pasa. Suponiendo que searchText tiene como valor "pan", es como decir:
            // title contiene pan
                   notes = selectedCategory?.notes.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "dateCreation", ascending: true)
            tableView.reloadData()
        }
    }
 
    //hace una busqueda global si despues de cambiar el texto (por ejemplo al pulsar la x del searchbar o borrar todo el texto) hace una busqueda global.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
           loadNotes()
            
            //searchBar.resignFirstResponder() quita el foco del searchbar y lo devuelve a la ventana, pero deja el searchbar en otro hilo.
            // por eso hay que "comunicarlo " al hilo principal usando el manejo de hilos dispatchqueue. pasando al hilo principal
            // de forma asincrona ejecute el clouser.
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
}

//extension para el swipetablecell
//en el main storyboard hay que añadir la clase SwipeTableViewCell y el modulo SwipeCellKit a la celda.
extension NotesTableViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else{
        
            guard orientation == .left else{return nil}
            let delectedAction = SwipeAction(style: .destructive, title: "borrar tambien") {
                action, indexPath in
                self.borrarNotes(indexRow: indexPath.row)
                
            }
            
            delectedAction.image = UIImage(named: "TrashIcon")
            
            return [delectedAction]
        
        }
        
        let delectedAction = SwipeAction(style: .destructive, title: "Borrar") {
            action, indexPath in
            self.borrarNotes(indexRow: indexPath.row)
            
        }
        
        delectedAction.image = UIImage(named: "TrashIcon")
        
        return [delectedAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
}
