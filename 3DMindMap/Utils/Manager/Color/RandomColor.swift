import SwiftUI

class RandomColor {
    public func getRandomColor(_ excludeColor: String?) -> String {
        var color: String
        if excludeColor == nil {
            return CustomColor.randomColors.randomElement() ?? CustomColor.defaultColor
        }
        repeat {
            color = CustomColor.randomColors.randomElement() ?? CustomColor.defaultColor
        } while color == excludeColor
        
        return color
    }
}
