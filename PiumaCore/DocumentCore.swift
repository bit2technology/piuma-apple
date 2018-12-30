import Foundation

public class DocumentCore: Codable {

    public var requests: [Request]
    public var undoManager: UndoManager?
    
    public init() {
        requests = []
    }

    public static func decode(data: Data) throws -> DocumentCore {
        return try JSONDecoder().decode(DocumentCore.self, from: data)
    }

    public func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(self)
    }

    private enum CodingKeys: String, CodingKey {
        case requests
    }
}
