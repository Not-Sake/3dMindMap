import SwiftUI

class RandomColor {
    public func getRandomColor(_ excludeColor: Color?) -> Color {
        var color: Color
        if excludeColor == nil {
            return CustomColors.randomColors.randomElement()!
        }
        repeat {
            color = CustomColors.randomColors.randomElement()!
        } while color == excludeColor
        
        return color
    }
}
