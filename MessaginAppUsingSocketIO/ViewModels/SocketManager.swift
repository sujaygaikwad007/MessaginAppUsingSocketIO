import Foundation
import SocketIO


class SocketManager: ObservableObject {
    private var manager: SocketIO.SocketManager
    private var socket: SocketIOClient

    @Published var messages: [ChatMessage] = []
    @Published var username: String = ""

    init() {
        self.manager = SocketIO.SocketManager(socketURL: URL(string: "http://localhost:8000")!, config: [.log(true), .compress])
        self.socket = self.manager.defaultSocket

        self.socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }

        self.socket.on("private message") { (data, ack) in
            if let dict = data[0] as? [String: Any],
               let sender = dict["sender"] as? String,
               let message = dict["message"] as? String {
                let isSender = sender == self.username
                DispatchQueue.main.async {
                    self.messages.append(ChatMessage(text: "\(sender): \(message)", isSender: isSender))
                }
            }
        }

        self.socket.connect()
    }

    func registerUser(username: String) {
        self.username = username
        self.socket.emit("register", username)
    }

    func sendMessage(recipient: String, message: String) {
        self.socket.emit("private message", ["sender": self.username, "recipient": recipient, "message": message])
        DispatchQueue.main.async {
            self.messages.append(ChatMessage(text: "\(self.username): \(message)", isSender: true))
        }
    }
}
