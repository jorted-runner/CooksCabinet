//
//  aiBrain.swift
//  CooksCabinet
//
//  Created by Danny Ellis on 2/13/25.
//

import Foundation

struct OpenAIRequest: Codable {
    let model: String
    let store: Bool
    let messages: [[String: String]]
}

struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

class aiBrain {
    func fetchOpenAIResponse(requestString: String) {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
            print("Error: Missing OpenAI API Key")
            return
        }
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request
            .setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = OpenAIRequest(
            model: "gpt-4o",
            store: true,
            messages: [
                ["role": "system", "content": "You are a helpful assistant trained as a chef designed to output a recipe in JSON format. following this format {title: String, recipeDescription: String, ingredients: [String], instructions: [String]}"],
                ["role": "user", "content": requestString]
            ]
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            print("Error encoding request body:", error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching response:", error ?? "Unknown error")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                if let message = decodedResponse.choices.first?.message.content {
                    print("OpenAI Response:\n\(message)")
                }
            } catch {
                print("Error decoding response:", error)
            }
        }.resume()
    }
}
