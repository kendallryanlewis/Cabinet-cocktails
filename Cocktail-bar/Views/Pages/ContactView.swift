//
//  ContactView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 4/5/24.
//

import SwiftUI
import MessageUI

struct ContactView: View {
    @EnvironmentObject var session: SessionStore
    @Binding var isMenuOpen: Bool
    @State private var showingMailView = false
    @State private var showingWebView = false
    @State private var showingConfirmation = false
    @State private var name: String = ""
    @State private var message: String = ""

    var body: some View {
        ZStack {
            COLOR_BACKGROUND.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {

                    // ── Header ──────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CONTACT")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .kerning(1)
                        Text("Get In Touch")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                        Text("We'd love to hear from you")
                            .font(.system(size: 14))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                    }
                    .padding(.top, 28)
                    .padding(.horizontal, 20)

                    // ── Help Link ───────────────────────────────────────
                    Button(action: { showingWebView = true }) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(COLOR_WARM_AMBER.opacity(0.14))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(COLOR_WARM_AMBER)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Need Help?")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                                Text("Visit our help page for FAQs and guides")
                                    .font(.system(size: 13))
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                            }
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                        }
                        .padding(16)
                        .background(COLOR_CHARCOAL_LIGHT)
                        .cornerRadius(14)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)

                    // ── Contact Form ────────────────────────────────────
                    VStack(alignment: .leading, spacing: 20) {
                        Text("SEND A MESSAGE")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .kerning(1)

                        VStack(spacing: 14) {
                            contactField(label: "Name", placeholder: "Enter your name", text: $name)

                            // Message
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Message")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                ZStack(alignment: .topLeading) {
                                    if message.isEmpty {
                                        Text("Tell us what's on your mind...")
                                            .font(.system(size: 16))
                                            .foregroundColor(COLOR_TEXT_SECONDARY.opacity(0.6))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 14)
                                    }
                                    TextEditor(text: $message)
                                        .font(.system(size: 16))
                                        .foregroundColor(COLOR_TEXT_PRIMARY)
                                        .tint(COLOR_WARM_AMBER)
                                        .scrollContentBackground(.hidden)
                                        .padding(8)
                                }
                                .frame(minHeight: 130)
                                .background(Color.white.opacity(0.07))
                                .cornerRadius(13)
                            }
                        }

                        // Submit
                        let canSend = !name.isEmpty && !message.isEmpty
                        Button(action: {
                            if MFMailComposeViewController.canSendMail() {
                                showingMailView = true
                            } else {
                                showingConfirmation = true
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "paperplane.fill")
                                Text("Send Message")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(canSend ? COLOR_CHARCOAL : COLOR_TEXT_SECONDARY)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(canSend ? COLOR_WARM_AMBER : Color.white.opacity(0.07))
                            .cornerRadius(14)
                        }
                        .disabled(!canSend)
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 48)
                }
            }
        }
        .sheet(isPresented: $showingMailView) {
            MailView(subject: "Contact from \(name)", messageBody: "Name: \(name)\nMessage: \(message)")
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

    @ViewBuilder
    private func contactField(label: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(COLOR_TEXT_SECONDARY)
            TextField(placeholder, text: text)
                .font(.system(size: 16))
                .foregroundColor(COLOR_TEXT_PRIMARY)
                .tint(COLOR_WARM_AMBER)
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.07))
                .cornerRadius(13)
        }
    }
}

struct TransparentTextEditor_Previews: PreviewProvider {
    static var previews: some View {
        TransparentTextEditor(text: .constant("Message"))
            .background(Color.clear)
            .previewLayout(.sizeThatFits)
    }
}

struct TransparentTextEditor: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 18)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var subject: String = ""
    var recipients: [String] = ["kndl.inc@gmail.com"]
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

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailView>) {}
}
