import GoogleGenerativeAI
import Foundation

let env = try? LoadEnv()

let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: "AIzaSyAnI6Ey8mJ3baFB1J28_HvZsboiX6i82-w")

struct GetIdeasRepository {
    let content: String
    
    func get() async -> [String]? {
            let prompt = """
            Provide three words associated with the given word, in a JSON format resembling an array of strings.
            Word: \(content)
            """
            
            do {
                // 1. モデルからレスポンスを取得
                let response = try await model.generateContent(prompt)
                
                // 2. レスポンスのテキスト部分があるか確認
                if let text = response.text {
                    // 3. 余分な部分を削除
                    let cleanedString = text
                        .replacingOccurrences(of: "```json\n", with: "")
                        .replacingOccurrences(of: "\n```", with: "")
                    
                    // 4. JSON デコード
                    if let jsonData = cleanedString.data(using: .utf8) {
                        do {
                            let decodedArray = try JSONDecoder().decode([String].self, from: jsonData)
                            print(decodedArray)
                            return decodedArray
                        } catch {
                            print("JSON decoding failed: \(error.localizedDescription)")
                        }
                    } else {
                        print("Failed to convert string to data.")
                    }
                } else {
                    print("Response did not contain any text.")
                }
            } catch {
                print("Error generating content: \(error.localizedDescription)")
            }
            
            // 5. 失敗時に nil を返す
            return nil
        }
}
