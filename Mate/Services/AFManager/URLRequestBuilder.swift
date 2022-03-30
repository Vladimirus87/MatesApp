//
//  URLRequestBuilder.swift
//  AlamofireManager
//
//  Created by Vladimirus on 20.01.2022.
//

import Foundation
import Alamofire

protocol URLRequestBuilder: URLRequestConvertible {
    var baseURL: String { get }
    var path: String { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get }
    var method: HTTPMethod { get }
}

extension URLRequestBuilder {

    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL()
        
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers?.dictionary
        
        print("~ method ~", request.httpMethod ?? "")
        print("~ url ~", url.appendingPathComponent(path))
        print("~ headers ~", request.allHTTPHeaderFields ?? [:])
        print("~ parameters ~", parameters ?? [:])
        
        switch method {
        case .post, .put:
            request = try JSONEncoding.default.encode(request, with: parameters)
        default:
            request = try URLEncoding.default.encode(request, with: parameters)
            break
        }
        
        return request
    }


}


