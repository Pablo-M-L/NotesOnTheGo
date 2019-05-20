//
//  ViewController.swift
//  NotesOnTheGo
//
//  Created by admin on 09/05/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RealmSwift

class CategoriesViewController: UICollectionViewController {

    //se mantiene actualizado en tiempo real por realm
    var categories: Results<Category>?
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
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
        loadCategories()
    }
   

    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories?.count ?? 0 //si categories es nulo el valor devuelto será 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCollectionViewCell
        
        let category = categories![indexPath.row]
        
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
            destinationVC.selectedCategory = categories![selectCategory]
            
        }
    }
    
    func loadCategories(){
        //recupera los items de Category. Devuelve un objeto results<caegories> de la clase categorias.
        categories = realm.objects(Category.self)
        collectionView.reloadData()
        
    }

}

    
    

