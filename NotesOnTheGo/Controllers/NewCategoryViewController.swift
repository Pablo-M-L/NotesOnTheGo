//
//  NewCategoryViewController.swift
//  NotesOnTheGo
//
//  Created by admin on 16/05/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import CoreData

class NewCategoryViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var hexLabel: UILabel!
    
    
    //los outlets collection crean una array de variables, cada posicion del array  corresponde a un elemento asignado al outlets collection.
    @IBOutlet var colorSliders: [UISlider]!
    
    @IBOutlet var colorLabels: [UILabel]!
    
    let imagePicker = UIImagePickerController()
    
    let colorKeys = ["R","G","B","A"]
    
    //crea una referencia a la clase delegate para acceder a la propiedad persistentContainer y obtener el contexto de esta aplicacion.
    //con UIApplication.shared.delegate as! AppDelegate; accedemos a la app en tiempo ejecucion, a un singleton llamado shared
    //que devuelve una instancia unica de la aplicacion, y esa instancia si tiene una propiedad delegate que  casteamos a un Appdelegate
    //porque sabemos que solo hay un delegate.
    //de aqui obtenemos la propiedad persistentContainer y su viewContext.
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //escuchador de gestos para que llame a una funcion cuando se pulse en algun elemento de la pantalla.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        
        //hacemos que la imagen sea intectiva y "haga algo" cuando se pulsa en ella.
        imageView.isUserInteractionEnabled = true
        //le asignamos la variable con el escuchador de gestos.
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        imagePicker.delegate = self

    }
    
    //cada eslader tiene un tag distinto pero el mismo metodo.
    @IBAction func sliderMoved(_ sender: UISlider) {
        
        colorLabels[sender.tag].text = "\(colorKeys[sender.tag]): \(lroundf(sender.value*255.0))"
        repaintBackground()
        
    }
    
    
    @IBAction func savePressed(_ sender: UIButton) {
        let category = Category(context: context)
        category.title = textField.text
        category.colorHex = hexLabel.text
        category.image = imageView.image?.pngData()//jpegData(compressionQuality: 0.5)
        
        do {
            try context.save()
        } catch {
            fatalError("error al intentar guardar el contexto \(error)")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imageViewTapped(){
        //muestra alert para seleccionar la forma de elegir la imagen
        let controller = UIAlertController(title: "selecciona una imagen", message: "", preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "camara de fotos", style: .default, handler: { (action) in
            self.presentImagePicker(with: .camera)
        }))
        controller.addAction(UIAlertAction(title: "carrete", style: .default, handler: { (action) in
            self.presentImagePicker(with: .photoLibrary)
        }))
        controller.addAction(UIAlertAction(title: "album de fotos", style: .default, handler: { (action) in
            self.presentImagePicker()
        }))
        self.present(controller,animated: true, completion: nil)
    }
    
    func presentImagePicker(with sourceType: UIImagePickerController.SourceType = .savedPhotosAlbum){
        //hay que añadir dos privacy:
        // camera usage description
        // photolibrary usage description
        // media library usage description
        //permitir o no la edicion de la imagen por parte del usuario.
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        //imagePicker.mediaTypes = [kCIAttributeTypeImage]
        present(imagePicker, animated: true, completion: nil)
    }
    
    func repaintBackground(){
        let backColor = UIColor(red: CGFloat(colorSliders[0].value), green: CGFloat(colorSliders[1].value), blue: CGFloat(colorSliders[2].value), alpha: CGFloat(colorSliders[3].value))
        
        self.view.backgroundColor = backColor
        
        //pasamos a hexadecimal los valores rgb con la extension de UIColor creada y lo ponemos en la hexlabel.
        self.hexLabel.text = backColor.toHex
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


//el delegado del texfield se asigna directamente en el main.storyboard arrastrando desde el  textfield hasta el icono del viewcontroller de la parte superior.
extension NewCategoryViewController: UITextFieldDelegate{
    
    //para ocultar el teclado al pulsar intro.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// extension para implementar los delegados de seleccinar foto y abrir camara fotos.
extension NewCategoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    // si el usuarion selecciona o hace una foto. devuelve la imagen en un diccionario.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage{
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    // si el usuario no selecciona o hace ninguna foto, cierra el imagePicker y devuelve el control a la app.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
