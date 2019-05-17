//
//  Extensions.swift
//  NotesOnTheGo
//
//  Created by admin on 15/05/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    
    //constructor especial que crea un color a partir de un valor hexadecimal.
    convenience init? (hex: String) {
        //version normalizada del hexadecimal, quita espacios en blanco y saltos de linea.
        var hexNormalize = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        // quitar la almoadilla (hastag)
        hexNormalize = hexNormalize.replacingOccurrences(of: "#", with: "")
        
        //variable rgba
        var rgb: UInt32 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        //averiga la longitud para saber si es con canal alfa o no, con 6 caracteres es sin alfa.
        let length = hexNormalize.count
        
        //parsea a valor binario de 32 bits el string y lo almacena en la variable rgb que se pasa por copia.
        Scanner(string: hexNormalize).scanHexInt32(&rgb)
        
        if length == 6 {
            //coge el par de digitos del hexadecimal y lo convierte en un decimal del 0 a 1.
            //con 0x indica que es  binario hexadecimal y con >>16 lo reduce de hexadecimal a decimal, devolviendo un numero entre 0 y 255.
            //dividiendo entre 255.0 para obtener un numero entre 0 y 1.
            r = CGFloat((rgb & 0xff0000)>>16)/255.0
            g = CGFloat((rgb & 0x00ff00)>>8)/255.0
            b = CGFloat((rgb & 0x0000ff))/255.0
        }
        else if length == 8 {
            r = CGFloat((rgb & 0xff000000)>>24)/255.0
            g = CGFloat((rgb & 0x00ff0000)>>26)/255.0
            b = CGFloat((rgb & 0x0000ff00)>>8)/255.0
            a = CGFloat((rgb & 0x000000ff))/255.0
        }
        else{
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
        
        
    }
    
    //variable que se guardará en el coredata
    var toHex: String? {
        
        //devuelve un array con los valores de r, g, b, a
        guard let components = cgColor.components, components.count >= 3 else { return nil }
        
        //variables RGBA
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4{
            a = Float(components[3])
        }
        
        //creamos el hex string, que es el que irá guardado en coredata.
        let hex = String(format: "%02lX%02lX%02lX%02lX", lroundf(r*255), lroundf(g*255), lroundf(b*255), lroundf(a*255))
    
        
        return hex
    }
    
}
//-------------------------------------------------------------------------------
// extensiones para los botones
@IBDesignable extension UIButton{
    @IBInspectable var borderWidth: CGFloat{
        
        set{
            layer.borderWidth = newValue
        }
        get{
            return layer.borderWidth
        }
        
    }
    
    @IBInspectable var cornerRadius: CGFloat{
        
        set{
            layer.cornerRadius = newValue
        }
        get{
            return layer.cornerRadius
        }
        
    }
    
    @IBInspectable var borderColor: UIColor?{
        
        set{
            guard let uiColor = newValue else {return}
            layer.borderColor = uiColor.cgColor
        }
        get{
            guard let color = layer.borderColor else{return nil}
            return UIColor(cgColor: color)
        }
        
    }
}


