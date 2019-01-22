

import UIKit
import Contacts
class Person: NSObject {
    var faceId: String!
    var avatar: UIImage!
}

class Photo: NSObject {
    var faceIds: [String]!
    var image: UIImage!

    var name: String?
    var phoneNumber: [String] = [String]()
    var email: [String] = [String]()
    
    var photoData: String?
    
    init(contact: CNContact) {
        name  = contact.givenName + " " + contact.familyName
        for phone in contact.phoneNumbers {
            phoneNumber.append(phone.value.stringValue)
        }
        for mail in contact.emailAddresses {
            email.append(mail.value as String)
        }
    }
    
    override init() {
        
    }
}

class ContentManager: NSObject {
    
    static let shared = ContentManager()
    private(set) var persons: [Person] = []
    private(set) var photos: [Photo] = []
    
    lazy var allPhotosFaceIds: [String] = {
        var allFaceIds: [String] = []
        for photo in photos {
            allFaceIds.append(contentsOf: photo.faceIds)
        }
        return allFaceIds
    }()
    
    func load(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            let (avatarDatas, avatarImages) = self.loadImages(at: "/Images/Avatars")
            let allContacts = self.fetchAddressBookRecords()
            for (avatarData, avatarImage) in zip(avatarDatas, avatarImages) {
                if let faceId = AzureFaceRecognition.shared.syncDetectFaceIds(imageData: avatarData).first {
                    let person = Person()
                    person.faceId = faceId
                    person.avatar = avatarImage
                    self.persons.append(person)
                }
            }
            
            // Create Photos
            for contacts in allContacts {
                let image = UIImage.init(data: contacts.imageData ?? Data(), scale: UIScreen.main.scale)!
                let faceIds = AzureFaceRecognition.shared.syncDetectFaceIds(imageData: contacts.imageData ?? Data())
                if !faceIds.isEmpty {
                    let photo = Photo(contact: contacts)
                    photo.faceIds = faceIds
                    photo.image = image
                    self.photos.append(photo)
                }
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func loadImages(at path: String) -> ([Data], [UIImage]) {
        var datas: [Data] = []
        var images: [UIImage] = []
        let fullFolderPath = Bundle.main.resourcePath!.appending(path)
        let imageNames = try! FileManager.default.contentsOfDirectory(atPath: fullFolderPath)
        for imageName in imageNames {
            let imageUrl = fullFolderPath.appending("/\(imageName)")
            let data = try! Data.init(contentsOf: URL(fileURLWithPath: imageUrl))
            let image = UIImage.init(data: data, scale: UIScreen.main.scale)!
            datas.append(data)
            images.append(image)
        }
        return (datas, images)
    }
    
    
    private func loadContactImages(at path: String) -> ([Data], [UIImage]) {
        var datas: [Data] = []
        var images: [UIImage] = []
        let fullFolderPath = Bundle.main.resourcePath!.appending(path)
        let imageNames = try! FileManager.default.contentsOfDirectory(atPath: fullFolderPath)
        for imageName in imageNames {
            let imageUrl = fullFolderPath.appending("/\(imageName)")
            let data = try! Data.init(contentsOf: URL(fileURLWithPath: imageUrl))
            let image = UIImage.init(data: data, scale: UIScreen.main.scale)!
            datas.append(data)
            images.append(image)
        }
        return (datas, images)
    }
    
    func photos(withFaceIds faceIds: [String]) -> [Photo] {
        var filteredPhotos: [Photo] = []
        let faceIdsSet = Set(faceIds)
        for photo in photos {
            let hasFaceIds = Set(photo.faceIds).intersection(faceIdsSet).isEmpty == false
            if hasFaceIds {
                filteredPhotos.append(photo)
            }
        }
        return filteredPhotos
    }
    
    
    func fetchAddressBookRecords()-> [CNContact] {
        let store = CNContactStore()
        var contacts = [CNContact]()
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),CNContactImageDataKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try store.enumerateContacts(with: request) {
                (contact, stop) in
                contacts.append(contact)
            }
        }
        catch {
            
        }
        print(contacts)
        var _: [Data] = []
        var _: [UIImage] = []
        var contactsWithImages = [CNContact]()
        for contact in contacts {
            let data = contact.imageData
            if(data != nil){
                contactsWithImages.append(contact)
            }
        }
        return contactsWithImages
    }
}
