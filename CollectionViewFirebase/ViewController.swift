//
//  ViewController.swift
//  CollectionViewFirebase
//


import UIKit
import Firebase
import CoreServices
import FirebaseUI

class ViewController: UIViewController{

    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var coleccion: UICollectionView!
    
    var images: [StorageReference] = [] //Devuelve una nueva instancia que apunta a una ubicación secundaria de la referencia actual.
    
    let placeholderImage = UIImage(named:"placeholder")//imagen por defecto
    
    let storage = Storage.storage()
    
    let i = Int.random(in: 1...1000) //generación de números aleatorios para las imagenes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Se crea un tipo de archivo especial para almacenar las interfaces de usuario es un documento de Interface Builder.
        //Devuelve una vistainicializado con el archivo nib.
        let nib = UINib.init(nibName: "ImageCollectionViewCell", bundle: nil)
        //Con base al nib creado se usa para las nuevas celdas de las imagenes a mostrar
        coleccion.register(nib, forCellWithReuseIdentifier: "imageCellXIB")
        constrainsAll()
        getImages()
        downloadImage()
    }
    
    @IBAction func uploadImage(_ sender: UIButton){
        //Se hace una instancia a UIImagePickerController para acceder a los archivos multimedia del dispositivo
        let userImagePicker = UIImagePickerController()
        userImagePicker.delegate = self
        userImagePicker.sourceType = .photoLibrary //se obtiene el contenido del dispositivo
        userImagePicker.mediaTypes = ["public.image"]//selecciona el tipo de contenido a obtener
        present(userImagePicker, animated: true, completion: nil)
    }
    
    func uploadImage(imageData: Data){
        let i = Int.random(in: 1...1000) //generación de números aleatorios para las imagenes
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images").child("profile").child("firebase").child("image_"+String(i))//se crea la ruta dentro de firebase para el guardado de la imagen, dado la referencia de la misma
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"//se obtiene el tipo de metadatos de la imagen espeficando en este caso el tipo de imagen
        
        imageRef.putData(imageData, metadata: uploadMetaData) { (metadata, error) in
            if let error = error{
                print(error.localizedDescription)
            } else {
                print("Image metadata: \(String(describing: metadata))")
                self.images.append(imageRef)// si no existe algun error se agrega al arreglo de las referencias de las imagenes
                self.userImageView.sd_setImage(with: imageRef, placeholderImage: self.placeholderImage)
                self.coleccion.reloadData()// se recarga el CollectionView
                
            }

        }

    }
    
    func getImages(){
        let storageRef = storage.reference().child(("images/profile/firebase/"))
        storageRef.listAll{ (result, error ) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                for item in result.items {
                    self.images.append(item)
                }
                DispatchQueue.main.async {
                self.coleccion.reloadData()
                }
            }
            
        }
    }
    
    func constrainsAll() {
        coleccion.translatesAutoresizingMaskIntoConstraints = false
        coleccion.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.55).isActive = true
        coleccion.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.25).isActive = true
        coleccion.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        coleccion.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    }
    
    func downloadImage(){
        
        let storageRef = storage.reference()
        
        let imageDownloadUrlRef = storageRef.child("images/profile/image_"+String(i))//en caso se descargar la imagenesse guarda en dicha ruta
        
        images.append(imageDownloadUrlRef)
        
        userImageView.sd_setImage(with: imageDownloadUrlRef, placeholderImage: placeholderImage)

        
        imageDownloadUrlRef.downloadURL { (url, error) in
            if let error = error{
                print(error.localizedDescription)
            } else {
                print("URL:  \(String(describing: url!))")
            }
        }
        
    }
    
}

extension ViewController: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let optimizedImageData = userImage.jpegData(compressionQuality: 0.6){
            uploadImage(imageData: optimizedImageData)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UINavigationControllerDelegate{
    
}


extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //se agregan secciones de acuerdo a la longitud de imagenes
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Se establece el reuso de la celda del tipo nib
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCellXIB", for: indexPath) as! ImageCollectionViewCell
        
        let ref = images[indexPath.item] //se obtiene el indice de la imagen
        
        cell.imageViewCell.sd_setImage(with: ref, placeholderImage: placeholderImage)//se inserta la imagen sustituyendo el placeholder
        
        ref.downloadURL { (url, error) in
            if let error = error{
                print(error.localizedDescription)
            } else {
                print("URL:  \(String(describing: url!))")
            }
        }
        
        return cell
    }
    
}

extension ViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell//se obtiene el contenido de la celda
        let storyboard = UIStoryboard(name: "Main", bundle: nil)//se establece Main como el principal del storyboard
        let viewData = storyboard.instantiateViewController(withIdentifier: "metadata") as! MetadataViewController //inicializa MetadataViewController con todos los objetos
        viewData.referencia = self.images[indexPath.item]//se alamcena el indice dentro de un objeto de viewData
        print("Referencia \(self.images[indexPath.item])")
        self.present(viewData, animated: true)//presenta a viewData en el controlador principal

    }
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)//establece el ancho y alto de
    }
}
