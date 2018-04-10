import Foundation

extension Dictionary  {
    
    /// SwifterSwift: Merge the keys/values of two dictionaries.
    /// https://github.com/SwifterSwift/SwifterSwift/blob/master/Sources/Extensions/SwiftStdlib/DictionaryExtensions.swift
    ///        let dict : [String : String] = ["key1" : "value1"]
    ///        let dict2 : [String : String] = ["key2" : "value2"]
    ///        let result = dict + dict2
    ///        result["key1"] -> "value1"
    ///        result["key2"] -> "value2"
    ///
    /// - Parameters:
    ///   - lhs: dictionary
    ///   - rhs: dictionary
    /// - Returns: An dictionary with keys and values from both.
    public static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        var result = lhs
        rhs.forEach { result[$0] = $1 }
        return result
    }
    
    /// SwifterSwift: Append the keys and values from the second dictionary into the first one.
    ///
    ///        var dict : [String : String] = ["key1" : "value1"]
    ///        let dict2 : [String : String] = ["key2" : "value2"]
    ///        dict += dict2
    ///        dict["key1"] -> "value1"
    ///        dict["key2"] -> "value2"
    ///
    /// - Parameters:
    ///   - lhs: dictionary
    ///   - rhs: dictionary
    public static func += (lhs: inout [Key: Value], rhs: [Key: Value]) {
        rhs.forEach { lhs[$0] = $1}
    }
}

extension JSONEncoder {
    func encodeJSONWithErrors<T:Encodable>(_ value: T)  -> Data?  {
        
        func printContext(_ ctx:EncodingError.Context) {
            print("  DebugDesc: \(ctx.debugDescription)")
            // NSError is not bridged with Error on Linux
            if let underErr  = ctx.underlyingError as? NSError,
                let debugDesc = underErr.userInfo["NSDebugDescription"]
            {
                print("  Underlying Error: \(debugDesc)")
            }
            for codeKey in ctx.codingPath {
                print("  Coding Key: \(codeKey.stringValue)")
            }
        }
        
        do {
            return try self.encode(value)
        } catch EncodingError.invalidValue(let badVal, let ctx) {
            print("EncodingError: invalidValue: \(badVal)")
            printContext(ctx)
        } catch let error {
            print("Error:\(error.localizedDescription)")
        }
        return nil
    }
}

extension JSONDecoder {
    func decodeJSONWithErrors<T:Decodable>(data:Data) -> T? {
        
        func printContext(_ ctx:DecodingError.Context) {
            print("  DebugDesc: \(ctx.debugDescription)")
            // NSError is not bridged with Error on Linux
            if let underErr  = ctx.underlyingError as? NSError,
                let debugDesc = underErr.userInfo["NSDebugDescription"]
            {
                print("  Underlying Error: \(debugDesc)")
            }
            for codeKey in ctx.codingPath {
                print("  Coding Key: \(codeKey.stringValue)")
            }
        }
        do {
            return try self.decode(T.self, from:data)
        } catch DecodingError.dataCorrupted(let ctx) {
            print("DecodingError: Data Corrupted")
            printContext(ctx)
        } catch DecodingError.keyNotFound(let codingKey, let ctx) {
            print("DecodingError: KeyNotFound: \(codingKey)")
            printContext(ctx)
        } catch DecodingError.typeMismatch(let typ, let ctx) {
            print("DecodingError: TypeMismatch: \(typ)")
            printContext(ctx)
        } catch DecodingError.valueNotFound(let typ, let ctx) {
            print("DecodingError: ValueNotFound:\(typ)")
            printContext(ctx)
        } catch let error {
            print("Error:\(error.localizedDescription)")
        }
        return nil
    }
}
