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
    @EnvironmentObject var session: SessionStore
    @Binding var isMenuOpen: Bool
    @State private var showingMailView = false
    @State private var showingWebView = false
    @State private var showingConfirmation = false
    @State private var actionConfirmed = false
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var message: String = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: colorScheme == .dark ?
                Gradient(colors: [LINEAR_BOTTOM, LINEAR_BOTTOM]) :
                    Gradient(colors: [LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM]),
                startPoint: .topTrailing,
                endPoint: .leading
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.circle.fill")
                                .font(.iconSmall)
                                .foregroundColor(COLOR_WARM_AMBER)
                            Text("Contact & Help")
                                .font(.cocktailTitle)
                                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                        }
                        Text("We'd love to hear from you")
                            .font(.bodyText)
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 24)
                    .padding(.horizontal, 20)
                    
                    // Help Link Card
                    Button(action: {
                        showingWebView = true
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.iconMini)
                                .foregroundColor(COLOR_WARM_AMBER)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Need Help?")
                                    .font(.cardTitle)
                                    .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                Text("Visit our help page for FAQs and guides")
                                    .font(.ingredientText)
                                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.navTitle)
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                        .padding(20)
                        .background(AdaptiveColors.cardBackground(for: colorScheme))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    
                    // Contact Form
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Send us a message")
                                .font(.sectionHeader)
                                .foregroundColor(COLOR_WARM_AMBER)
                            
                            VStack(spacing: 16) {
                                // Name field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Name")
                                        .font(.ingredientText)
                                        .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                    TextField("Enter your name", text: $name)
                                        .font(.bodyText)
                                        .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                        .padding(12)
                                        .background(AdaptiveColors.secondaryCardBackground(for: colorScheme))
                                        .cornerRadius(8)
                                }
                                
                                // Email field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Email")
                                        .font(.ingredientText)
                                        .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                    TextField("your@email.com", text: $email)
                                        .font(.bodyText)
                                        .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                        .padding(12)
                                        .background(AdaptiveColors.secondaryCardBackground(for: colorScheme))
                                        .cornerRadius(8)
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
                                }
                                
                                // Message field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Message")
                                        .font(.ingredientText)
                                        .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                    ZStack(alignment: .topLeading) {
                                        if message.isEmpty {
                                            Text("Tell us what's on your mind...")
                                                .font(.bodyText)
                                                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 20)
                                        }
                                        TextEditor(text: $message)
                                            .font(.bodyText)
                                            .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                            .padding(8)
                                            .scrollContentBackground(.hidden)
                                            .background(Color.clear)
                                    }
                                    .frame(minHeight: 150)
                                    .background(AdaptiveColors.secondaryCardBackground(for: colorScheme))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(20)
                            .background(AdaptiveColors.cardBackground(for: colorScheme))
                            .cornerRadius(12)
                            
                            // Submit button
                            Button(action: {
                                if MFMailComposeViewController.canSendMail() {
                                    showingMailView = true
                                } else {
                                    showingConfirmation = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                    Text("Send Message")
                                }
                                .font(.bodyText)
                                .fontWeight(.semibold)
                                .foregroundColor(COLOR_CHARCOAL)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(name.isEmpty || email.isEmpty || message.isEmpty ? COLOR_TEXT_SECONDARY : COLOR_WARM_AMBER)
                                .cornerRadius(12)
                            }
                            .disabled(name.isEmpty || email.isEmpty || message.isEmpty)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 60)
                }
            }
            .sheet(isPresented: $showingMailView) {
                MailView(subject: "Contact from \(name)", messageBody: "Name: \(name)\nEmail: \(email)\nMessage: \(message)")
            }
            .sheet(isPresented: $showingWebView) {
                WebView(url: URL(string: "\(WEBSITE_URL)/Cabinet-cocktails")!)
            }
            .alert("Mail Not Available", isPresented: $showingConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please configure your email app to send messages.")
            }
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
    var recipients: [String] = ["kndl.inc@gmail.com"] // Default recipient
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
