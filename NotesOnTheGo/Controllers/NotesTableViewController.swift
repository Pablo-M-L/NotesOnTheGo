//
//  NotesTableViewController.swift
//  NotesOnTheGo
//
//  Created by admin on 09/05/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController {

    //var notesArray  = [String]()
    //var notesArray  = [NoteModel]()
    var notesArray = [Note]()
    var selectedCategory: Category? {
        didSet{
            loadNotes()
        }
    }


    //como no se puede guardar objetos que no sean propios del sistema en un userDefaults,
    // vamos a crear un archivo plis (property List) propio en la carpeta documents de la aplicacion.
    
    //obtiene la ruta de la carpeta documents de la aplicacion.
    // se le pasa como argumento .documentDirectory para indicar en que carpeta queremos buscar. (cada app tiene las carpetas de descargas, documentos...)
    // y userDomainMask para guardar la informacion en el sistema de carpetas del usuario del dispositivo.
    //devuelve un array de rutas posibles del que se coge el primer item, con first.
    //añadimos una referencia a un archivo en la carpeta con appendigPath....
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Notes.plist")
    
    //crea una referencia a la clase delegate para acceder a la propiedad persistentContainer y obtener el contexto de esta aplicacion.
    //con UIApplication.shared.delegate as! AppDelegate; accedemos a la app en tiempo ejecucion, a un singleton llamado shared
    //que devuelve una instancia unica de la aplicacion, y esa instancia si tiene una propiedad delegate que  casteamos a un Appdelegate
    //porque sabemos que solo hay un delegate.
    //de aqui obtenemos la propiedad persistentContainer y su viewContext.
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //recupera los datos de tipo string guardados en el plist, como preferencias de usuario.
        /*if let previousNotes = defaults.array(forKey: "NotesArray") as? [String]{
            self.notesArray = previousNotes
        }*/
        
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
        
        //borra la nota seleccionada.
        //borrarNotes(indexRow: indexPath.row)
        persistNotes()
        
        //tableView.cellForRow(at: indexPath)?.accessoryType = (note.checked ? .checkmark : .none)
        
        //funcion que evita que la celda se quede de color gris al seleccionarla.
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: añadir nuevos item a la tabla.
    
    @IBAction func addNewNote(_ sender: UIBarButtonItem) {
        
        //let note = NoteModel()

        //ahora note es una instancia de un objeto core data. Note es la entidad.
        let note = Note(context: self.context)
        
        var textField = UITextField()
        
        let alerta = UIAlertController(title: "Añadir nueva nota", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Añade un item", style: .default) { (action) in
            
            // guarda los datos en el plist de user preferends
            /*self.notesArray.append(textField.text!)
            
            //guarda el array completo asociado a una clave en la variable defaults para la persistencia de datos.
            self.defaults.set(self.notesArray, forKey:  "NotesArray")
            */
            
            note.title = textField.text!
            note.parentCategory = self.selectedCategory
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
    
    //persistencia de datos usando core data.
    //guarda en el coredata el array.
    func persistNotes(){
        //codigo basado en el saveConext del appdelegate.
        do {
            try context.save()
        } catch {
            fatalError("error al intentar guardar el contexto \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //hace una consulta para descargar todos los items y añadirlos al array.
    // si no se pasa ningun argumento toma como valor por defecto una busqueda global
    func loadNotes(from request: NSFetchRequest<Note> = Note.fetchRequest(), predicate: NSPredicate? = nil){
        
        // let request : NSFetchRequest<Note> = Note.fetchRequest()
        
        //creamos un predicado que buscará en la relacion parentCategory, el titulo de la categoria y lo comparará con el titulo recibido en el segue dentro de la vaiable selectedCategory.
        let catgoryPredicate = NSPredicate(format: "parentCategory.title MATCHES %@", selectedCategory!.title!)
        
        //si hay un predicado previo pasado por argumento, que seria en caso de busqueda desde la search bar.
        if let previousPredicate = predicate{
        
            //hacemos un predicado compuesto por los dos predicados unidos por AND.
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [previousPredicate, catgoryPredicate])
            request.predicate = compoundPredicate
        }
        else{
            //sino hay un predicado previo, filtra solo por la categoria seleccionada.
            request.predicate = catgoryPredicate
        }

        do{
            notesArray = try context.fetch(request)
        }catch{
            print("error al recuperar datos coredata \(error)")
        }
        
        tableView.reloadData()
    }
    
    //borra un item del array.
    func borrarNotes(indexRow: Int){
    //hay que seguir un orden para que funcione.
        //primero borramos el objeto en el contexto.
        context.delete(notesArray[indexRow])
        
        // despues se borra del array.
        notesArray.remove(at: indexRow)
    }
    
    
    //persistencia de datos codificando y descodificando un property list creado por nosostros.
    /*
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
                //un array de tipo NoteModel. y se pone .self para indicar que se trata de dicha clase.
                notesArray = try decoder.decode([NoteModel].self, from: data)
            }catch{
                print("error al decodificar o leer el array \(error)")
            }
        }
 
    }
    */
    
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
            //inicializa la peticion (devolveria todas si se ejecutase asi.
            let request : NSFetchRequest<Note> = Note.fetchRequest()
            //predicado de busqueda, con formato y argumentos.
            // en este caso busca en cualquier item en el que el title contenga el texto pasado como argumento.
            // %@ significa que esos signos se sustituyen por el argumento que se le pasa. Suponiendo que searchText tiene como valor "pan", es como decir:
            // title contiene pan
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
            //pasamos el predicado a la consulta.
            
            //ordenar por title
            let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            
            loadNotes(from: request, predicate: predicate)
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
