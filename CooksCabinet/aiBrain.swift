//
//  aiBrain.swift
//  CooksCabinet
//
//  Created by Danny Ellis on 2/13/25.
//

import Foundation
import UIKit

struct OpenAIRecipeRequest: Codable {
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

struct OpenAIRecipeResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

struct OpenAIImageRequest: Codable {
    let model: String
    let prompt: String
    let n: Int?
    let size: String?
}

struct OpenAIImageResponse: Codable {
    struct Data: Codable {
        let url: String
    }
    let data: [Data]
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
    func generateRecipe(requestString: String, data: UpdateEditFormViewModel, completion: @escaping (String?) -> Void) {
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
        
        let body = OpenAIRecipeRequest(
            model: "gpt-4o-mini",
            store: true,
            messages: [
                OpenAIRecipeRequest.Message(
                    role: "developer",
                    content: [
                        OpenAIRecipeRequest.Content(
                            type: "text",
                            text: "You are a helpful assistant trained as a chef designed to output a recipe in JSON format. following this format {title: String, recipeDescription: String, ingredients: [String], instructions: [String]}",
                            image_url: nil
                        )
                    ]
                ),
                OpenAIRecipeRequest.Message(
                    role: "user",
                    content: [
                        OpenAIRecipeRequest.Content(type: "text", text: requestString, image_url: nil),
                        OpenAIRecipeRequest.Content(type: "image_url", text: nil, image_url: ["url": base64ImageDataURL])
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
                    OpenAIRecipeResponse.self,
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
    
    func generateImage(title: String, description: String, completion: @escaping (String?) -> Void) {
        guard let apiKey = Bundle.main.infoDictionary?["OPEN_AI_API_KEY"] as? String else {
            print("Error: Missing OpenAI API Key")
            completion(nil)
            return
        }
        let requestString = "Generate an image based off the title and description of this recipe. Title: \(title), Description: \(description)."
        let body = OpenAIImageRequest(
            model: "dall-e-3",
            prompt: requestString,
            n: 1,
            size: "1024x1024"
        )
        let url = URL(string: "https://api.openai.com/v1/images/generations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            print("Error encoding request body:", error)
            completion(nil)
            return
        }
        
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
                    OpenAIImageResponse.self,
                    from: data
                )
                if let message = decodedResponse.data.first?.url {
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
    
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                print("Failed to load image:", error?.localizedDescription ?? "Unknown error")
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
