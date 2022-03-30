//
//  NetworkManager.swift
//  AlamofireManager
//
//  Created by Vladimirus on 20.01.2022.
//

import Foundation
import Alamofire

enum ResultHandle<T: Codable> {
    case success(T)
    case failure(Error)
}


class NetworkManager<T: URLRequestBuilder> {
    func request<U: Codable>(service: T, decodable: U.Type, completion: @escaping (ResultHandle<U>)->()) {
        guard let urlRequest = service.urlRequest else {
            return
        }
        
        AF.request(urlRequest)
            .validate()
            .responseDecodable(of: U.self) { response in
            switch response.result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    func upload<U: Codable>(image: UIImage, service: T, decodable: U.Type, completion: @escaping (ResultHandle<U>)->()) {
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(image.jpegData(compressionQuality: 0.9)!, withName: "file" , fileName: "file.jpeg", mimeType: "image/jpeg")
        }, with: service)
            .responseString(completionHandler: { str in
                print(str)
            })
            .validate()
            .responseDecodable(of: U.self) { response in
                switch response.result {
                case .success(let result):
                    completion(.success(result))
                case .failure(let error):
                    completion(.failure(error))
                }
                
            }
        
    }
    
    
    func empty(service: T, completion: @escaping (Bool)->()) {
        guard let urlRequest = service.urlRequest else {
            return
        }
        AF.request(urlRequest)
            .response(completionHandler: { resp in
                if resp.response?.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            })
            
        }
    
    

}

