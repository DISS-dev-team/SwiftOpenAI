import Foundation

public struct MessageChatGPT: Identifiable, Hashable {
    public var id: UUID
    public var text: String
    public var role: MessageRoleType
    public var date: Date

    public init(text: String, role: MessageRoleType, date: Date = Date(), id: UUID = UUID()) {
        self.id = id
        self.text = text
        self.role = role
        self.date = date
    }
}
