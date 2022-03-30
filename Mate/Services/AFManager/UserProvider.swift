//
//  UserProvider.swift
//  AlamofireManager
//
//  Created by Vladimirus on 20.01.2022.
//

import Foundation
import Alamofire

enum UserProvider: URLRequestBuilder {
    
    case getUserInfo
    case getCardInfo
    case updateUserInfo(data: User)
    case getUsers(params: PaginationParams)
    case getUser(userID: Int)
    case updateUserPass(params: PasswordParams)
    case uploadPhoto
    case deletePhoto
    case getCompanyShort
    case getNotifications(params: PaginationParams)
    case viewNotification(params: NotificationViewBody)
    case sendMessage(params: MessageParams)
    case getMessage(messageID: Int)
    case getOrder(orderID: Int)
    case getOrders(params: OrdersParams)
    case createOrder(params: CreateOrderParams)
    case getTransfer(transferID: Int)
    case sendTransfer(params: TransferParams)
    case getDeposit(depositID: Int)
    case getCardHistory(params: PaginationParams)
    case getProductsCategory(params: CategoryParams)
    case getProducts(params: ProductParams)
    case getProduct(productID: Int)
    case getNotes
    
    var baseURL: String {
        switch self {
        case .getProductsCategory, .getProducts, .getProduct:
            return "http://167.99.44.4/app/v1/"
        default:
            return "http://104.248.192.94/app/v1/"
        }
        
//        switch self {
//        case .getCompanyShort, .getOrder:
//            return "http://167.99.44.4/app/v1/"
//        case .getNotifications, .viewNotification:
//            return "http://165.22.195.85/app/v1/"
//        default:
//            return "http://128.199.51.163/app/v1/"
//        }
    }
    
    var path: String {
        switch self {
            //users
        case .getCardInfo:
            return "users/full-info"
        case .getUserInfo, .updateUserInfo:
            return "users/info"
        case .uploadPhoto, .deletePhoto:
            return "users/photos"
        case .getUsers:
            return "users/search"
        case .getUser(let userID):
            return "users/info/\(userID)"
        case .updateUserPass:
            return "users/password"
            
            //companies
        case .getCompanyShort:
            return "companies/short"
        case .getNotifications:

            //notifications
            return "notifications/search"
        case .viewNotification:
            return "notifications/view"

            //messages
        case .getMessage(let messageID):
            return "messages/\(messageID)"
        case .sendMessage:
            return "messages"

            //orders
        case .getOrders:
            return "orders/search"
        case .getOrder(let orderID):
            return "orders/\(orderID)"
        case .createOrder:
            return "orders"

            //transfers
        case .getTransfer(let transferID):
            return "transfers/\(transferID)"
        case .sendTransfer:
            return "transfers"

            //deposits
        case .getDeposit(let depositID):
            return "deposits/\(depositID)"

            //transactions
        case .getCardHistory:
            return "transactions/search"
        
        case .getProductsCategory:
            return "products/categories/search"
        case .getProducts:
            return "products/search"
        
        case .getProduct(let productID):
            return "products/\(productID)"
            
        case .getNotes:
            return "companies/notes/search"
        }
    }
    
    var headers: HTTPHeaders? {
        
        guard let token = AccessService.shared.token else {
            return nil
        }
        var header = [HTTPHeader(name: "Authorization", value: "Bearer \(token)")]
        
        switch self {
        case .uploadPhoto:
            header.append(HTTPHeader(name: "Content-type", value: "multipart/form-data"))
            return HTTPHeaders(header)

        default:
            return HTTPHeaders(header)
        }
    }
    
    
    
    var parameters: Parameters? {
        switch self {
        case .getCardInfo:
            return ["balance": true]
            
        case .updateUserInfo(let user):
            return try? user.toDictionary()
            
        case .updateUserPass(let params):
            return try? params.toDictionary()
            
        case .getUsers(let params):
            return try? params.toDictionary()
            
        case .getNotifications(let params):
            return try? params.toDictionary()
            
        case .viewNotification(let params):
            return try? params.toDictionary()
            
        case .getCardHistory(let params):
            return try? params.toDictionary()
        
        case .sendTransfer(let params):
            return try? params.toDictionary()
        
        case .sendMessage(let params):
            return try? params.toDictionary()
            
        case .getProductsCategory(let params):
            return try? params.toDictionary()
            
        case .getProducts(let params):
            return try? params.toDictionary()
            
        case .getOrders(let params):
            return try? params.toDictionary()
            
        case .createOrder(let params):
            return try? params.toDictionary()
        
        default:
            return nil
        }
        
    }
    
    var method: HTTPMethod {
        switch self {
        case .uploadPhoto, .getNotifications, .viewNotification, .getCardHistory, .sendTransfer, .getUsers, .sendMessage, .updateUserPass, .getProductsCategory, .getProducts, .getOrders, .createOrder, .getNotes:
            return .post
            
        case .updateUserInfo:
            return .put
        
        case .deletePhoto:
            return .delete
            
        default:
            return .get
        }
    }
    
}

