//
//  InformationVC.swift
//  Mate
//
//  Created by Vladimirus on 23.12.2021.
//

import UIKit
import QCropper

class InformationVC: FatherViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var sernameField: UITextField!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var photoButton: DesignableButton!
    @IBOutlet weak var textFieldBirthday: UITextField!
    @IBOutlet weak var textFieldPosition: UITextField!

    @IBOutlet private var datePicker: UIDatePicker!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet weak var actionButton: DesignableButton!
    
    private lazy var networkManager = NetworkManager<UserProvider>()
    
    private let cellIdentifier = "HobbieCell"
    
    private var user: User? {
        didSet {
            if let _user = user, _user != AccessService.shared.user {
                actionButton.enableButton()
            }
            updatePhotoButton()
        }
    }
    
    private var hobbies: [String] {
        return user?.hobbies ?? []
    }

    
    private let contentInset: UIEdgeInsets = UIEdgeInsets(top: 11, left: 0, bottom: 0, right: 0)
    
    private var birthday: Date? {
        didSet {
            textFieldBirthday.text = dateFormatterUI.string(from: birthday ?? Date())
            datePicker.date = birthday ?? Date()
            user?.dateOfBirth = birthday?.getString(format: "yyyy-MM-dd")
        }
    }
    
    private let queue = DispatchQueue(label: "UserInformationQueue", attributes: .concurrent)
    private let anotherQueue = DispatchQueue(label: "UserInformationQueue2", attributes: .concurrent)
    
    private var defaultPhoto: UIImage! {
        return UIImage(named: "User-Default-Photo")!
    }
    
    private lazy var dateFormatterUI: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "ru-RU")
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        isKeyboardObserving = true
        isActiveMainView = true
        super.viewDidLoad()
        uiSettings()
        initAllNibs()
        
        DispatchQueue.main.async {
            self.fetchData()
        }
    }
    
    private func initAllNibs() {
        collectionView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }
    
    private func uiSettings() {
        navigationItem.backButtonTitle = ""
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
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
        textFieldPosition.setBorder()
        textFieldPosition.setLeftPaddingPoints(15)
        
        actionButton.disableButton()
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
    
    override func localizations() {
        title = "Информация"
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    private func fetchData() {
        user = AccessService.shared.user
        updateUser()
    }
    
    private func updateUser() {
        nameField.text = user?.name
        sernameField.text = user?.lastName
        birthday = user?.dateOfBirth?.getDate()
        textFieldPosition.text = user?.position
//        userPhoto.kf.setImage(with: user?.photoURL, placeholder: defaultPhoto)
        collectionView.reloadData()
    }
    
    
    private func updatePhotoButton() {
        if let photo = user?.photo, !photo.isEmpty {
            photoButton.setTitle("Изменить фото", for: .normal)
            userPhoto.kf.setImage(with: user?.photoURL, placeholder: defaultPhoto)
        } else {
            photoButton.setTitle("Добавить фото", for: .normal)
            userPhoto.image = defaultPhoto
        }
    }
    
    
    private func allFieldsFull() -> Bool  {
        var allFieldsCorrect = true
        let requiered = stackView.subviews.filter({$0 is UITextField}).compactMap({$0 as? UITextField})
        requiered.forEach { tf in
            if tf.checkEmpty() {
                allFieldsCorrect = false
            }
        }
        return allFieldsCorrect
    }
    
    
    @IBAction func fieldEditingChange(_ sender: UITextField) {
        switch sender {
        case nameField:
            user?.name = sender.text
        case sernameField:
            user?.lastName = sender.text
        case textFieldPosition:
            user?.position = sender.text
        default:
            break
        }
    }
    
    
    
    @IBAction func addHobbiePressed(_ sender: Any) {
        fieldAlert { [unowned self] value in
            DispatchQueue.main.async {
                self.user?.hobbies?.append(value)
                let row = (self.user?.hobbies?.count ?? 1) - 1
                let ip = IndexPath(row: row, section: 0)
                self.collectionView.insertItems(at: [ip])
                self.collectionView.scrollToRight(animated: true)
            }
        }
    }
    
    @IBAction private func doneDateTapped(_ sender: Any) {
        textFieldBirthday.resignFirstResponder()
        birthday = datePicker.date
        actionButton.enableButton()
    }

    @IBAction private func cancelDateTapped(_ sender: Any) {
        textFieldBirthday.resignFirstResponder()
    }
    
    @IBAction func addPhotoPressed(_ sender: Any) {
        addPhoto()
    }
    
    @IBAction func showPhotoPressed(_ sender: Any) {
        guard userPhoto.image != defaultPhoto else { return }
        let vc = PhotoDetaiVC(nibName: "PhotoDetaiVC", bundle: nil)
        vc.image = userPhoto.image
        present(vc, animated: true)
    }
    
    @IBAction func changePassPressed(_ sender: Any) {
        let vc = PasswordChangeVC.fromStoryboard(.account)
        navigationController?.show(vc, sender: nil)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        hideKeyboard()
        guard allFieldsFull() else {
            MessageView.sharedInstance.showOnViewWithError("Все обязательные поля должны быть заполнены")
            return
        }
        startAnimating()
        
        queue.async {
            self.saveUserData()
        }
    }
    
    
}



//MARK: - UIImagePickerControllerDelegate
extension InformationVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
    
    private func showImagePicker(type: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.modalPresentationStyle = .fullScreen
        picker.sourceType = type

        if type == .camera {
            picker.cameraDevice = .front
            picker.cameraCaptureMode = .photo
        }
        
        DispatchQueue.main.async {
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    
    private func addPhoto() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .black
        
        let delete = UIAlertAction(title: "Удалить текущее фото", style: .default) { (_) in
            self.startAnimating()
            self.queue.async {
                self.deletePhoto()
            }
        }
        if let photo = user?.photo, !photo.isEmpty {
            alert.addAction(delete)
        }
        
        let takePhoto = UIAlertAction(title: "Сделать фото", style: .default) { (_) in
            self.showImagePicker(type: .camera)
        }
        alert.addAction(takePhoto)
        
        let gallery = UIAlertAction(title: "Выбрать из галереи", style: .default) { (_) in
            self.showImagePicker(type: .photoLibrary)
        }
        alert.addAction(gallery)

        alert.addAction(.init(title: "Отмена", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}



extension InformationVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hobbies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! HobbieCell
        cell.updateInformationData(hobbie: hobbies[indexPath.row])
        cell.delegate = self
        return cell
    }
    
}


extension InformationVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (hobbies[indexPath.row].width(withConstrainedHeight: 27, font: UIFont.regular(ofSize: 15))) + 40
            return CGSize(width: width, height: 27)
    }
}


extension InformationVC: HobbieCellDelegate {
    func hobbieItemPressed(_ item: UICollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: item) {
            let alert = UIAlertController(title: "Удалить", message: "Действительно хотите удалить хобби \"\(hobbies[indexPath.row])\"?", preferredStyle: .alert)
            let delete = UIAlertAction(title: "Удалить", style: .default) { (_) in
                DispatchQueue.main.async {
                    self.removeHobbie(with: indexPath)
                }
            }
            
            let cancel = UIAlertAction(title: "Отмена", style: .cancel)
            alert.addAction(delete)
            alert.addAction(cancel)
            
            present(alert, animated: true)
        }
    }
    
    
    func removeHobbie(with indexPath: IndexPath) {
        self.user?.hobbies?.remove(at: indexPath.row)
        self.collectionView.deleteItems(at: [indexPath])
    }
    
}



extension InformationVC: CropperViewControllerDelegate {
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

    
}


extension InformationVC {
    private func uploadCroppedPhoto(_ photo: UIImage) {
        networkManager.upload(image: photo, service: .uploadPhoto, decodable: Photo.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let photoMD):
                    self.user?.photo = photoMD.url
                    self.anotherQueue.async {
                        self.saveUserData(isPop: false)
                    }
                case .failure(let error):
                    self.stopAnimating()
                    MessageView.sharedInstance.showError(error)
                }
            }
            
        }
    }
    
    private func deletePhoto() {
        networkManager.empty(service: .deletePhoto) { isSuccess in
            DispatchQueue.main.async {
                if isSuccess {
                    self.user?.photo = ""
                    self.anotherQueue.async {
                        self.saveUserData(isPop: false)
                    }
                } else {
                    self.stopAnimating()
                    MessageView.sharedInstance.showOnViewWithError("Упс, ошибка сервера(")
                }
            }
        }
    }
    
    private func saveUserData(isPop: Bool = true) {
        networkManager.request(service: .updateUserInfo(data: user!), decodable: User.self) { result in
            DispatchQueue.main.async {
                self.stopAnimating()
                switch result {
                case .success(let userMD):
                    AccessService.shared.user = userMD
                    NotificationCenter.default.post(name: NotifyIdentifiers.updateCardSum, object: nil)
                    if isPop {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.fetchData()
                    }
                    
                case .failure(let error):
                    MessageView.sharedInstance.showError(error)
                }
            }
            
        }
    }
}
