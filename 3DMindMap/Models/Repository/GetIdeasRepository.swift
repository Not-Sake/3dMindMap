
import Foundation
import Alamofire

let env = try! LoadEnv()

//let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: "AIzaSyB8PMdY-uHFRWZD79lOxjWIuateNsAFIME")

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

    //    func get() async -> [String]? {
    //        let prompt = """
    //            Three minor words of minor types related to a given word are provided in JSON format, similar to an array of strings: \(content)
    //            """
    //
    //        do {
    //            // 1. モデルからレスポンスを取得
    //            let response = try await model.generateContent(prompt)
    //
    //            // 2. レスポンスのテキスト部分があるか確認
    //            if let text = response.text {
    //                // 3. 余分な部分を削除
    //                let cleanedString = text
    //                    .replacingOccurrences(of: "```json\n", with: "")
    //                    .replacingOccurrences(of: "\n```", with: "")
    //
    //                // 4. JSON デコード
    //                if let jsonData = cleanedString.data(using: .utf8) {
    //                    do {
    //                        let decodedArray = try JSONDecoder().decode([String].self, from: jsonData)
    //                        print(decodedArray)
    //                        return decodedArray
    //                    } catch {
    //                        print("JSON decoding failed: \(error.localizedDescription)")
    //                    }
    //                } else {
    //                    print("Failed to convert string to data.")
    //                }
    //            } else {
    //                print("Response did not contain any text.")
    //            }
    //        } catch {
    //            print("Error generating content: \(error.localizedDescription)")
    //        }
    //
    //        // 5. 失敗時に nil を返す
    //        return nil
    //    }
    //}
}
