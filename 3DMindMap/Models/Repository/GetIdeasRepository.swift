
import Foundation
import Alamofire

let env = try! LoadEnv()

struct GetIdeasRepository {
    let content: String
    func getGeminiIdeas() async -> [String] {
        let prompt = """
           「\(content)」に関連するマイナーな日本語単語を3つ、以下の形式でJSONで返してください（前後に説明は不要です）:

           ["〇〇", "〇〇", "〇〇"]
        """

        let url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
        let params: Parameters = [
            "contents":[
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        let headers: HTTPHeaders = [
            "Content-Type":"application/json",
        ]

        do {
            let data = try await AF.request("\(url)?key=\(env.value("APIKEY") ?? "")",
                                            method: .post,
                                            parameters: params,
                                            encoding: JSONEncoding.default,
                                            headers: headers)
                .serializingDecodable(GeminiResponse.self).value

            if let text = data.candidates.first?.content.parts.first?.text {
                let cleaned = text
                    .replacingOccurrences(of: "```json\n", with: "")
                    .replacingOccurrences(of: "\n```", with: "")

                if let jsonData = cleaned.data(using: .utf8) {
                    let result = try JSONDecoder().decode([String].self, from: jsonData)
                    return result
                }
            }

        } catch {
            print("🚨 エラー:", error)
        }

        return []
    }

    struct GeminiResponse: Codable {
        let candidates: [Candidate]
        let usageMetadata: UsageMetadata
        let modelVersion: String
    }

    struct Candidate: Codable {
        let content: Content
        let finishReason: String
        let avgLogprobs: Double
    }

    struct Content: Codable {
        let parts: [Part]
        let role: String
    }

    struct Part: Codable {
        let text: String
    }

    struct UsageMetadata: Codable {
        let promptTokenCount: Int
        let candidatesTokenCount: Int
        let totalTokenCount: Int
    }

}
