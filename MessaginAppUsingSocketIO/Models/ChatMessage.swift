
import Foundation

struct ChatMessage: Identifiable {
    var id = UUID()
    var text: String
    var isSender: Bool
}
