//
//  ChatGPTApi.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 4/8/24.
//

import Foundation
import SwiftUI

struct OpenAIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    
    struct Choice: Codable {
        let text: String
        let index: Int
        let logprobs: Int?
        let finish_reason: String
    }
}

class ChatGPTViewModel: ObservableObject {
    @Published var responseText = ""
    
    func fetchResponse(prompt: String) {
        guard let url = URL(string: "https://api.openai.com/v1/completions") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer <Your_OpenAI_API_Key>", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        let body: [String: Any] = [
            "model": "text-davinci-003",
            "prompt": prompt,
            "temperature": 0.7,
            "max_tokens": 256
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let response = try? JSONDecoder().decode(OpenAIResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.responseText = response.choices.first?.text ?? "No response"
                }
            } else {
                print("Failed to decode response")
            }
        }.resume()
    }
}

class ImageViewModel: ObservableObject {
    @Published var generatedImage: UIImage? = nil
    
    func fetchGeneratedImage(prompt: String) {
        // Define the URL of your server endpoint
        guard let url = URL(string: "ttps://api.openai.com/v1/images/generations/generateImage") else { return }
        
        // Create your request body with the prompt
        let body: [String: String] = ["prompt": prompt]
        
        // Convert your request body to JSON data
        guard let jsonData = try? JSONEncoder().encode(body) else { return }
        
        // Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Perform the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for errors, and ensure we received data
            guard let data = data, error == nil else { return }
            
            // Convert the received data to a UIImage and update the published property
            DispatchQueue.main.async {
                self.generatedImage = UIImage(data: data)
            }
        }.resume()
    }
}
