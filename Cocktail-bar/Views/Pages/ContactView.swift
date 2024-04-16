//
//  ContactView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 4/5/24.
//

import SwiftUI
import MessageUI

struct ContactView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isMenuOpen: Bool
    @State private var showingMailView = false
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var message: String = ""

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                // Title and description
                HStack{
                    VStack(alignment: .leading){
                        Text("Contact Us")
                            .bold()
                            .font(.title)
                            .foregroundColor(colorScheme == .dark ? .white : .darkGray)
                    }
                    Spacer().frame(width: 100)
                }.padding(.bottom)
                Text("Name").bold()
                TextField("Enter your name", text: $name)
                    .padding()
                    .background(colorScheme == .dark ? Color.white.opacity(0.3) : .darkGray.opacity(0.5))
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                Text("Email").bold()
                TextField("Enter your email", text: $email)
                    .padding()
                    .background(colorScheme == .dark ? Color.white.opacity(0.3) : .darkGray.opacity(0.5))
                    .cornerRadius(10)
                    .padding(.bottom, 20)

                Text("Message").bold()
                ZStack{
                    if message.isEmpty {
                          Text("")
                              .foregroundColor(.gray)
                              .padding(.horizontal, 5)
                              .padding(.vertical, 8)
                      }
                      TextEditor(text: $message)
                          .padding(4)
                          .background(Color.clear) // Attempt to set background to transparent
                  }
                .frame(minHeight: 150)
                .padding(5)
                .background(colorScheme == .dark ? Color.white.opacity(0.3) : .darkGray.opacity(0.5))
                .cornerRadius(10)
                .padding(.bottom, 20)

                Button(action: {
                    if MFMailComposeViewController.canSendMail() {
                        showingMailView = true
                    } else {
                        // Alert the user that mail services are not available
                        print("Cannot send mail")
                        // Consider providing an alternative like copying the email address to the clipboard
                    }
                }) {
                    Spacer()
                    Text("Submit").padding()
                    Spacer()
                }
                .foregroundColor(colorScheme == .dark ? .darkGray : COLOR_PRIMARY)
                .background(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                .cornerRadius(8)
                .disabled(name.isEmpty || email.isEmpty || message.isEmpty)
            }
            .padding(40)
        }
        .sheet(isPresented: $showingMailView) {
            MailView(subject: "Contact from \(name)", messageBody: "Name: \(name)\nEmail: \(email)\nMessage: \(message)")
        }
    }
}

struct TransparentTextEditor_Previews: PreviewProvider {
    static var previews: some View {
        TransparentTextEditor(text: .constant("Message"))
            .background(Color.clear) // To test the transparency against a dark background
            .previewLayout(.sizeThatFits)
    }
}
struct TransparentTextEditor: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear // Make background transparent
        textView.font = UIFont.systemFont(ofSize: 18) // Adjust font size as needed
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}


struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var subject: String = ""
    var recipients: [String] = ["support@gmail.com"] // Default recipient
    var messageBody: String = ""
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode
        
        init(presentation: Binding<PresentationMode>) {
            _presentation = presentation
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            $presentation.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentationMode)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = context.coordinator
        mailComposeVC.setSubject(subject)
        mailComposeVC.setToRecipients(recipients)
        mailComposeVC.setMessageBody(messageBody, isHTML: false)
        return mailComposeVC
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailView>) {
        // Implementation not needed for this example
    }
}
