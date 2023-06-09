import XCTest
@testable import SwiftOpenAI

final class ChatCompletionRequestSpec: XCTestCase {
    private let api = API()

    func testRequest_CreatedWithCorrectHeaders() throws {
        let apiKey = "123"
        let model: OpenAIModelType = .gpt3_5(.gpt_3_5_turbo_0613)
        let messages: [MessageChatGPT] = [.init(text: "Hello, who are you?", role: .user)]
        var endpoint = OpenAIEndpoints.chatCompletions(model: model, messages: messages, optionalParameters: nil).endpoint
        
        api.routeEndpoint(&endpoint, environment: OpenAIEnvironmentV1())
        
        var sut = api.buildURLRequest(endpoint: endpoint)
        api.addHeaders(urlRequest: &sut,
                       headers: ["Content-Type" : "application/json",
                                 "Authorization" : "Bearer \(apiKey)"])
        
        XCTAssertEqual(sut.allHTTPHeaderFields?.count, 2)
        XCTAssertEqual(sut.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(sut.allHTTPHeaderFields?["Authorization"], "Bearer \(apiKey)")
    }
}
