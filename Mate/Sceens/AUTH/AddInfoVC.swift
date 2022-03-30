//
//  AddInfoVC.swift
//  Mate
//
//  Created by Vladimirus on 20.12.2021.
//

import UIKit
import QCropper


class AddInfoVC: FatherViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var photoButton: DesignableButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var sernameField: UITextField!
    @IBOutlet weak var textFieldBirthday: UITextField!
    @IBOutlet weak var positionField: UITextField!
    @IBOutlet weak var hobbiesField: UITextField!
    
    @IBOutlet private var datePicker: UIDatePicker!
    @IBOutlet var toolBar: UIToolbar!
    
    private let contentInset: UIEdgeInsets = UIEdgeInsets(top: 21, left: 0, bottom: 0, right: 0)
    
    private lazy var queue = DispatchQueue(label: "AddInfoFetchQueue", attributes: .concurrent)
    
    private lazy var dateFormatterUI: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "ru-RU")
        return dateFormatter
    }()
    
    
    var user: User? {
        return AccessService.shared.user
    }
    
    private lazy var networkManager = NetworkManager<UserProvider>()
    
    
    override func localizations() {
        title = "Заполните информацию"
    }
    
    private var birthday: Date? {
        didSet {
            textFieldBirthday.text = dateFormatterUI.string(from: birthday ?? Date())
        }
    }
    
    private var uploadedPhoto: Photo?
    private var photo: UIImage? {
        didSet {
            userPhoto.image = photo
            photoButton.setTitle("Изменить фото", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        isKeyboardObserving = true
        isActiveMainView = true
        super.viewDidLoad()
        uiSettings()
    }


    private func uiSettings() {
        datePicker.backgroundColor = .white
        textFieldBirthday.inputView = datePicker
        textFieldBirthday.inputAccessoryView = toolBar
        
        scrollView.contentInset = contentInset
        stackView.subviews.forEach { sub in
            if sub is UITextField {
                (sub as! UITextField).setBorder()
                (sub as! UITextField).setLeftPaddingPoints(15)
            }
        }
        
        updateUser(user)
    }
    
    private func updateUser(_ user: User?) {
        nameField.text = user?.name
        sernameField.text = user?.lastName
        birthday = user?.dateOfBirth?.getDate()
        positionField.text = user?.position
        hobbiesField.text = user?.hobbies?.joined(separator:", ")
    }
    
    
    override func keyboardWillShow(rect: CGRect) {
        guard scrollView.contentInset == contentInset else { return }
        scrollView.contentInset.bottom = rect.height
    }
    
    override func keyboardWillHide() {
        UIView.animate(withDuration: 0.5) {
            self.scrollView.contentInset = self.contentInset
            self.view.layoutIfNeeded()
        }
    }
    
    private func showImagePicker(type: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.modalPresentationStyle = .fullScreen
        if type == .camera {
            picker.cameraDevice = .front
        }
        if UIImagePickerController.isSourceTypeAvailable(type) {
            picker.sourceType = type
        }

        DispatchQueue.main.async {
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    private func allFieldsFull() -> Bool  {
        var allFieldsCorrect = true
        let requiered = stackView.subviews
            .filter({$0 is UITextField})
            .filter({$0.tag < 3})
            .compactMap({$0 as? UITextField})
        requiered.forEach { tf in
            if tf.checkEmpty() {
                print(tf.tag)
                allFieldsCorrect = false
            }
        }
        return allFieldsCorrect
    }
    
    
    @IBAction private func doneDateTapped(_ sender: Any) {
        textFieldBirthday.resignFirstResponder()
        birthday = datePicker.date
    }

    @IBAction private func cancelDateTapped(_ sender: Any) {
        textFieldBirthday.resignFirstResponder()
    }
    
    @IBAction func addPhotoPressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhoto = UIAlertAction(title: "Сделать фото", style: .default) { (_) in
            self.showImagePicker(type: .camera)
        }
        alert.addAction(takePhoto)
        let gallery = UIAlertAction(title: "Выбрать из галереи", style: .default) { (_) in
            self.showImagePicker(type: .photoLibrary)
        }
        alert.addAction(gallery)
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func savePressed(_ sender: Any) {
        hideKeyboard()
        guard allFieldsFull() else { return }
        
        let hobbies = hobbiesField?.value?
            .replacingOccurrences(of: ", ", with: ",")
            .split(separator: ",")
            .map({ String($0) })
        
        let user = User(dateOfBirth: birthday?.getString(format: "yyyy-MM-dd"),
                        hobbies: hobbies,
                        lastName: sernameField?.value,
                        middleName: nil,
                        name: nameField?.value,
                        photo: uploadedPhoto?.url,
                        position: positionField?.value,
                        userID: user?.userID)
        networkManager.request(service: .updateUserInfo(data: user), decodable: User.self) { result in
            switch result {
            case .success(let userMD):
                AccessService.shared.user = userMD
                let mainVC = UIStoryboard.StoryboardType.main.storyboard
                    .instantiateInitialViewController()!
                self.navigationController?.show(mainVC, sender: nil)
            case .failure(let error):
                print("error", error)
                    MessageView.sharedInstance.showError(error)
            }
        }
    }
    
    
}



//MARK: - UIImagePickerControllerDelegate
extension AddInfoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let cropper = CropperViewController(originalImage: image, isCircular: true)
            
            cropper.delegate = self
            
            picker.dismiss(animated: true) {
                self.present(cropper, animated: true, completion: nil)
            }
        }
        
    }
}


extension AddInfoVC: CropperViewControllerDelegate {
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        cropper.dismiss(animated: true, completion: nil)

        if let state = state,
            let image = cropper.originalImage.cropped(withCropperState: state) {
            startAnimating()
            
            queue.async {
                self.uploadCroppedPhoto(image)
            }
            
        }
    }
    
   
    
    private func uploadCroppedPhoto(_ photo: UIImage) {
        networkManager.upload(image: photo, service: .uploadPhoto, decodable: Photo.self) { result in
            DispatchQueue.main.async {
                self.stopAnimating()
                switch result {
                case .success(let photoMD):
                    self.uploadedPhoto = photoMD
                    self.photo = photo
                case .failure(let error):
                    print("error", error)
                    MessageView.sharedInstance.showError(error)
                }
            }
            
        }
    }
}
