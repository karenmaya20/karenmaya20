//
//  MetadataViewController.swift
//  CollectionViewFirebase
//
//  Created by mac on 10/04/21.
//

import UIKit
import Firebase
import FirebaseUI

class MetadataViewController: UIViewController {
    //Esta vista se utliza para ver los detalles de las imagenes que se van almacenando en Firebase

    @IBOutlet weak var detailImage: UIImageView! //Imagen seleccionada
    @IBOutlet weak var txt: UILabel! //Se utiliza para mostrar los detalles
    @IBOutlet weak var txt1: UILabel! //Se utiliza para mostrar los detalles
    @IBOutlet weak var txt2: UILabel!
    @IBOutlet weak var txt3: UILabel!

    var referencia : StorageReference? //variable que se utiliza para obtener los datos del enlace con ViewController
    let placeholderImage = UIImage(named:"placeholder")//imagen por defecto
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let referencia = self.referencia{
            detailImage.sd_setImage(with: referencia, placeholderImage: self.placeholderImage)//añadimos la imagen obteniendo su referencia
            referencia.getMetadata { metadata, error in
              if let error = error {
                print(error.localizedDescription)
              } else {
                let time = metadata!.timeCreated
                self.txt.text = "Name:" + referencia.name
                self.txt1.text = "Size:" + (String(describing: metadata!.size))
                self.txt2.text = "Time created:\(time!)"
                self.txt3.text = "FullPath:" + referencia.fullPath
              }
            }
        }
        
        constrainsAll()
        
    }
    
    func constrainsAll() {
        detailImage.translatesAutoresizingMaskIntoConstraints = false
        detailImage.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.55).isActive = true
        detailImage.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.25).isActive = true
        detailImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        detailImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 85).isActive = true
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
