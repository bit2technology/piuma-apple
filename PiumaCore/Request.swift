import Foundation

public class Request: Codable {
    public let id = UUID()
    public var name: String?
    public var url: String?
}
