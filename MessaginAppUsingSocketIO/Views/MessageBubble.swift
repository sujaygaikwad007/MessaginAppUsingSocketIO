import SwiftUI

struct MessageBubble: View {
    var message: String
    var isSender: Bool

    var body: some View {
        HStack {
            if isSender {
                Spacer()
            }
            Text(message)
                .padding()
                .background(isSender ? Color.blue : Color.gray.opacity(0.3))
                .cornerRadius(15)
                .foregroundColor(isSender ? Color.white : Color.black)
                .padding(isSender ? .leading : .trailing, 40)
                .padding(.vertical, 5)
            if !isSender {
                Spacer()
            }
        }
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MessageBubble(message: "Hello, how are you? what is your name", isSender: true)
            MessageBubble(message: "I'm good, thank you!", isSender: false)
        }
        .padding()
    }
}
