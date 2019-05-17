//
//  ViewController.swift
//  NotesOnTheGo
//
//  Created by admin on 09/05/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import CoreData

class CategoriesViewController: UICollectionViewController {

    var categoriesArray = [Category]()
        
    //crea una referencia a la clase delegate para acceder a la propiedad persistentContainer y obtener el contexto de esta aplicacion.
    //con UIApplication.shared.delegate as! AppDelegate; accedemos a la app en tiempo ejecucion, a un singleton llamado shared
    //que devuelve una instancia unica de la aplicacion, y esa instancia si tiene una propiedad delegate que  casteamos a un Appdelegate
    //porque sabemos que solo hay un delegate.
    //de aqui obtenemos la propiedad persistentContainer y su viewContext.
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //titulo en grande
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .automatic

        //atributos texto del titulo grande.
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.blue,
            NSAttributedString.Key.font : UIFont(name: "Papyrus", size: 24.0) ?? UIFont.systemFont(ofSize: 24.0),/* la segunda opcion es por si no existe la primera fuente indicada. */
            
        ]

    }
    
    override func viewDidAppear(_ animated: Bool) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let sortDescription = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescription]
        
        do{
            try categoriesArray = context.fetch(request)
        }catch{
            print("error al recuperar categorias \(error)")
        }
        
        collectionView.reloadData()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCollectionViewCell
        
        let category = categoriesArray[indexPath.row]
        
        cell.categoryLabel.text = category.title
        cell.categoryLabel.textColor = UIColor(hex: category.colorHex!)
        
        cell.categoryImageView.image = UIImage(data: category.image!)
        cell.categoryImageView.contentMode = .scaleAspectFit
        cell.categoryImageView.layer.borderColor = UIColor(hex: category.colorHex!)?.cgColor //le pasa el atributo cgColor del UIColor
        cell.categoryImageView.layer.borderWidth = 3
        cell.categoryImageView.layer.cornerRadius = 15
        cell.categoryImageView.backgroundColor = UIColor(hex: category.colorHex!)
        
        
        
        return cell
    }
    
    var selectCategory = -1
    // metodos de collectionview delegate.
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectCategory = indexPath.row
        performSegue(withIdentifier: "ShowNoteList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNoteList"{
            let destinationVC = segue.destination as! NotesTableViewController
            destinationVC.selectedCategory = categoriesArray[selectCategory]
            
        }
    }

    

}

