import SwiftUI

import SwiftUI

struct ChatView: View {
    @ObservedObject var socketManager = SocketManager()

    @State private var recipient = ""
    @State private var messageText = ""
    @State private var username = ""

    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        VStack {
            if socketManager.username.isEmpty {
                userRegistrationSection
            } else {
                chatSection
            }
        }
        .padding(.bottom, keyboardHeight)
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self.keyboardHeight = keyboardFrame.height
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
                self.keyboardHeight = 0
            }
        }
    }

  
}


extension ChatView{
    
    private var userRegistrationSection: some View {
        UserRegistrationSectionView(username: $username, registerAction: {
            socketManager.registerUser(username: username)
        })
    }

    private var chatSection: some View {
        ChatSectionView(socketManager: socketManager, recipient: $recipient, messageText: $messageText)
    }
}

extension ChatView {
    private struct UserRegistrationSectionView: View {
        @Binding var username: String
        var registerAction: () -> Void

        var body: some View {
            VStack {
                TextField("Enter your username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: registerAction) {
                    Text("Register")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }

    private struct ChatSectionView: View {
        @ObservedObject var socketManager: SocketManager
        @Binding var recipient: String
        @Binding var messageText: String

        var body: some View {
            VStack {
                ScrollView {
                    ScrollViewReader { proxy in
                        VStack(alignment: .leading) {
                            ForEach(socketManager.messages, id: \.id) { message in
                                MessageBubble(message: message.text, isSender: message.isSender)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal)
                        .onChange(of: socketManager.messages.count) { _ in
                            withAnimation {
                                proxy.scrollTo(socketManager.messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }

                TextField("Recipient", text: $recipient)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.leading, .trailing])

                HStack {
                    TextField("Message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(minHeight: CGFloat(30))

                    Button(action: {
                        socketManager.sendMessage(recipient: recipient, message: messageText)
                        messageText = ""
                    }) {
                        Text("Send")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .frame(minHeight: CGFloat(50))
                .padding()
            }
        }
    }
}


struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
