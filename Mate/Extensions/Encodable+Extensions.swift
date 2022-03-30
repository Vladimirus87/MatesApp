//
//  Encodable+Extensions.swift
//  Charme
//
//  Created by Vladimirus on 28.04.2020.
//  Copyright © 2020 Moses. All rights reserved.
//

import Foundation

extension Encodable {
    /// Converting object to postable dictionary
    func toDictionary(_ encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        let data = try encoder.encode(self)
        let object = try JSONSerialization.jsonObject(with: data)
        guard let json = object as? [String: Any] else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Deserialized object is not a dictionary")
            throw DecodingError.typeMismatch(type(of: object), context)
        }
        return json
    }
}

enum EncodableOptional<Wrapped>: ExpressibleByNilLiteral {
    case none
    case some(Wrapped)
    init(nilLiteral: ()) {
        self = .none
    }
}

extension EncodableOptional: Encodable where Wrapped: Encodable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .none:
            try container.encodeNil()
        case .some(let wrapped):
            try wrapped.encode(to: encoder)
        }
    }
}

extension EncodableOptional{

    var value: Optional<Wrapped> {

        get {
            switch self {
            case .none:
                return .none
            case .some(let v):
                return .some(v)
            }
        }

        set {
            switch newValue {
            case .none:
                self = .none
            case .some(let v):
                self = .some(v)
            }
        }
    }
}
