import Foundation
import SwiftyJSON

public protocol ChatCompletionsStreamMappeable {
    func parse(data: Data) throws -> [ChatCompletionsStreamDataModel]
}

public struct ChatCompletionsStreamMapper: ChatCompletionsStreamMappeable {
    private enum Constant: String {
        case streamData = "data: "
        case streamError = "\"error\": {\n"
        case streamFinished = "[DONE]"
    }

    public init() { }

    public func parse(data: Data) throws -> [ChatCompletionsStreamDataModel] {
        guard let dataString = String(data: data, encoding: .utf8) else {
            return []
        }
        return try extractDataLine(from: dataString).map {
            let json = JSON($0)
            
            print("DEBUG: From package => \(json)")
            
            if $0 == Constant.streamFinished.rawValue {
                return .finished
            }
            else{
                
                print("DEBUG: From PKG building model")
                
                return ChatCompletionsStreamDataModel(
                    id: json["id"].stringValue,
                    object: json["object"].stringValue,
                    created: json["created"].intValue,
                    model: json["model"].stringValue,
                    choices: json["choices"].arrayValue.map{
                        
                        print("DEBUG: From package Choice => \($0)")
                        
                        return .init(
                            delta: $0["delta"]["content"].string == nil ? nil : .init(content: $0["delta"]["content"].string),
                            index: $0["index"].intValue,
                            finishReason: $0["finish_reason"].string
                        )
                    }
                )
            }
            
            /*guard let jsonData = $0.data(using: .utf8) else {
                return nil
            }
            if $0 == Constant.streamFinished.rawValue {
                return .finished
            } else {
                
                return try decodeChatCompletionsStreamDataModel(from: jsonData)
            }*/
        }.compactMap { $0 }
    }

    private func extractDataLine(from dataString: String,
                                 dataPrefix: String = Constant.streamData.rawValue) throws -> [String] {
        if dataString.contains(Constant.streamError.rawValue) {
            return [dataString]
        } else {
            let lines = dataString.components(separatedBy: "\n\n")
                .filter { !$0.isEmpty }
            return lines.map {
                $0.dropFirst(dataPrefix.count).trimmingCharacters(in: .whitespaces)
            }
        }
    }

    private func decodeChatCompletionsStreamDataModel(from data: Data) throws -> ChatCompletionsStreamDataModel? {
        do {
            return try JSONDecoder().decode(ChatCompletionsStreamDataModel.self, from: data)
        } catch {
            let error = try JSONDecoder().decode(OpenAIAPIError.self, from: data)
            throw error
        }
    }
}
