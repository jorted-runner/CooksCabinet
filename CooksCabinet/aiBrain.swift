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
    let messages: [Message]
    
    struct Message: Codable {
        let role: String
        let content: [Content] // Allow content to be multiple types
    }
    
    struct Content: Codable {
        let type: String
        let text: String?
        let image_url: [String:String]?
    }
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

struct OpenAIErrorResponse: Codable {
    struct APIError: Codable {
        let message: String
        let type: String?
        let param: String?
        let code: String?
    }
    let error: APIError
}

class aiBrain {
    func fetchOpenAIResponse(requestString: String, data: UpdateEditFormViewModel, completion: @escaping (String?) -> Void) {
        guard let apiKey = Bundle.main.infoDictionary?["OPEN_AI_API_KEY"] as? String else {
            print("Error: Missing OpenAI API Key")
            completion(nil)
            return
        }
        guard let imageData = data.image.jpegData(compressionQuality: 0.8) else {
            print("Error: Unable to process image")
            completion(nil)
            return
        }
        let base64ImageString = imageData.base64EncodedString()
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let base64ImageDataURL = "data:image/jpeg;base64,\(base64ImageString)"
        
        let body = OpenAIRequest(
            model: "gpt-4o-mini",
            store: true,
            messages: [
                OpenAIRequest.Message(
                    role: "developer",
                    content: [
                        OpenAIRequest.Content(
                            type: "text",
                            text: "You are a helpful assistant trained as a chef designed to output a recipe in JSON format. following this format {title: String, recipeDescription: String, ingredients: [[quantity:String, name:String]], instructions: [String]}",
                            image_url: nil
                        )
                    ]
                ),
                OpenAIRequest.Message(
                    role: "user",
                    content: [
                        OpenAIRequest.Content(type: "text", text: requestString, image_url: nil),
                        OpenAIRequest.Content(type: "image_url", text: nil, image_url: ["url": base64ImageDataURL])
                    ]
                )
            ]
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            print("Error encoding request body:", error)
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) {
 data,
 response,
 error in
            guard let data = data,
 error == nil else {
                print("Error fetching response:", error ?? "Unknown error")
                completion(nil)
                return
            }
            
            do {
                // Try decoding a successful response
                let decodedResponse = try JSONDecoder().decode(
                    OpenAIResponse.self,
                    from: data
                )
                if let message = decodedResponse.choices.first?.message.content {
                    completion(
                        message
                    ) // Return the message via completion handler
                    return
                }
            } catch {
                // Check if it's an error response instead
                do {
                    let errorResponse = try JSONDecoder().decode(OpenAIErrorResponse.self, from: data)
                    print("OpenAI API Error: \(errorResponse.error.message)")
                } catch {
                    print("Unexpected API Response Format:", String(data: data, encoding: .utf8) ?? "Unknown response")
                }
            }
            completion(nil) // Ensure completion is called in case of failure
        }.resume()
    }
    
    func extractJSON(from response: String) -> String? {
        let pattern = #"```json\n([\s\S]*?)\n```"#  // Matches text inside ```json ... ```
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: response, options: [], range: NSRange(response.startIndex..., in: response)) {
            
            if let range = Range(match.range(at: 1), in: response) {
                return String(response[range])
            }
        }
        return nil
    }
}
