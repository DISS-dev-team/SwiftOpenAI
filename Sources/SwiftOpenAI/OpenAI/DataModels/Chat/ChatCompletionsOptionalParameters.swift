import Foundation

public struct ChatCompletionsOptionalParameters {
    public let temperature: Double?
    public let topP: Double?
    public let n: Int?
    public let responseFormat: [String: Any]?
    public let stop: [String]?
    public let stream: Bool
    public let maxTokens: Int?
    public let user: String?

    public init(
        temperature: Double = 1.0,
        topP: Double = 1.0,
        n: Int = 1,
        responseFormat: [String: Any]? = nil,
        stop: [String]? = nil,
        stream: Bool = false,
        maxTokens: Int? = nil,
        user: String? = nil
    ) {
        self.temperature = temperature
        self.topP = topP
        self.n = n
        self.responseFormat = responseFormat
        self.stop = stop
        self.stream = stream
        self.maxTokens = maxTokens
        self.user = user
    }
}
