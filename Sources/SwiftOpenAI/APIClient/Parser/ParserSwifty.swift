//
//  File.swift
//  
//
//  Created by Ever Cuevas on 13/8/24.
//

import Foundation
import SwiftyJSON

// Define the APIErrorSwifty enum
public enum APIErrorSwifty: Error {
    case jsonResponseError(String)
    case decodable(Error)
    case unknown
}

// Define the ParserSwiftyProtocol
public protocol ParserSwiftyProtocol {
    func parse<T: Decodable>(_ data: Data, type: T.Type) throws -> T?
    func parseError<E: Decodable & Error>(apiError: APIErrorSwifty, type: E.Type) throws -> E?
}

// Implement the Parser class
final public class ParserSwifty: ParserSwiftyProtocol {
    public init() { }

    public func parse<T: Decodable>(_ data: Data, type: T.Type) throws -> T? {
        let json = JSON(data)
        do {
            // Manually map JSON to the Decodable type T
            let decodedData = try jsonToDecodable(json, type: T.self)
            return decodedData
        } catch let decodingError as DecodingError {
            handleDecodingError(decodingError)
            throw APIErrorSwifty.decodable(decodingError)
        } catch {
            throw APIErrorSwifty.unknown
        }
    }

    public func parseError<E: Decodable & Error>(apiError: APIErrorSwifty, type: E.Type) throws -> E? {
        guard case APIErrorSwifty.jsonResponseError(let jsonString) = apiError,
              let jsonData = jsonString.data(using: .utf8) else {
            throw apiError
        }

        let json = JSON(jsonData)
        do {
            // Manually map JSON to the Decodable Error type E
            let decodedError = try jsonToDecodable(json, type: E.self)
            return decodedError
        } catch let decodingError as DecodingError {
            handleDecodingError(decodingError)
            throw APIErrorSwifty.decodable(decodingError)
        } catch {
            throw APIErrorSwifty.unknown
        }
    }

    // Helper method to convert SwiftyJSON's JSON to a Decodable object
    private func jsonToDecodable<T: Decodable>(_ json: JSON, type: T.Type) throws -> T {
        let data = try json.rawData()
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    // Handle Decoding Errors
    private func handleDecodingError(_ error: DecodingError) {
        let message: String
        switch error {
        case .keyNotFound(let key, let context):
            message = "[APIClient] Decoding Error: Key \"\(key)\" not found \nContext: \(context.debugDescription)"
        case .dataCorrupted(let context):
            message = "[APIClient] Decoding Error: Data corrupted \n(Context: \(context.debugDescription)) \nCodingKeys: \(context.codingPath)"
        case .typeMismatch(let type, let context):
            message = "[APIClient] Decoding Error: Type mismatch \"\(type)\" \nContext: \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            message = "[APIClient] Decoding Error: Value not found, type \"\(type)\" \nContext: \(context.debugDescription)"
        @unknown default:
            message = "[APIClient] Unknown DecodingError caught"
            assertionFailure(message)
        }
        print(message)
    }
}
