import SwiftUI

enum GameLevel: Int, CaseIterable {
    case level1 = 1, level2, level3, level4, level5, level6, level7, level8, level9, level10
    case level11, level12, level13, level14, level15, level16, level17, level18, level19, level20

    var emojis: [String] {
        switch self {
        case .level1:
            return ["👻", "🎃", "👽", "👹", "🤖", "🤡"]
        case .level2:
            return ["🍏", "🍎", "🍐", "🍊", "🍋", "🍓"]
        case .level3:
            return ["🇫🇷", "🇳🇱", "🇷🇺", "🇸🇮", "🇸🇰", "🇭🇷"]
        case .level4:
            return ["😁", "😆", "😄", "😃", "😀", "😅"]
        case .level5:
            return ["✋", "✋🏻", "✋🏼", "✋🏽", "✋🏾", "✋🏿"]
        case .level6:
            return ["🎆", "🎇", "🌅", "🌄", "🏙️", "🌃", "🌇", "🌆"]
        case .level7:
            return ["🧑‍🌾", "👩‍🌾", "👨‍🍳", "🧑‍🍳", "👩‍🍳", "👨‍🎓", "🧑‍🎓", "👩‍🎓"]
        case .level8:
            return ["🧛‍♀️", "🧛", "🧛‍♂️", "🦹‍♀️", "🦹‍♂️", "🦸‍♀️", "🦸", "🦸‍♂️"]
        case .level9:
            return ["◀️", "🔼", "🔽", "↘️", "↙️", "↖️", "➡️", "⬅️", "⬆️", "⬇️"]
        case .level10:
             return ["🌵", "🌲", "🌳", "🌴", "🌱", "🍀", "🌿", "☘️", "🌾", "🌺"]
        case .level11:
            return ["👉", "👈", "👆", "👇", "🤚", "🖐️", "🫷", "🫸", "🤘", "🤟"]
        case .level12:
            return ["🐵", "🙈", "🙉","🙊", "🐼", "🐭", "🐰", "🐻‍❄️", "🐑", "🐏"]
        case .level13:
            return ["🧘‍♀️", "🤽🏻‍♂️", "🏊🏻‍♀️", "🏄🏻‍♀️", "🧘🏼‍♀️", "🤽‍♂️", "🏄‍♀️", "🏊‍♀️", "🚴‍♂️", "🚴"]
        case .level14:
            return ["🌚", "🌝","🌕", "🌖", "🌗", "🌓", "🌒", "🌑", "🌔","🌘"]
        case .level15:
            return ["🏢", "🏬", "🏣", "🏤", "🏥", "🏦", "🏨", "🏪", "🏫", "🏩"]
        case .level16:
            return ["👯‍♀️", "👯‍♂️", "🤶", "🧖‍♂️", "🧝🏼‍♂️", "🧖🏻‍♀️", "🎅", "🧑‍🎄", "🧝‍♂️", "🧝🏾‍♂️"]
        case .level17:
            return ["👨‍🦽‍➡️", "👨‍🦼", "👩‍🦽‍➡️", "🧑‍🦼‍➡️", "👩‍🦼‍➡️", "🧑🏻‍🦽", "🧑‍🦽‍➡️", "🚶‍♀️‍➡️", "👩‍🦯‍➡️", "🚶"]
        case .level18:
            return ["🧚🏿‍♀️", "🧚🏿", "🧚🏿‍♂️", "🧞‍♂️", "🧞", "🧜", "🧟‍♂️", "🧟‍♀️", "🧙", "🧙‍♀️"]
        case .level19:
            return ["😞", "😒", "😏", "😟", "😕", "🙁", "😣", "😣", "😠", "☹️"]
        case .level20:
            return ["🕛", "🕐", "🕑", "🕒", "🕓", "🕔", "🕕", "🕖", "🕗", "🕘"]
        }
    }
    
    var numberOfPairs: Int {
        return emojis.count
    }
    
    var label: String {
        return "Level \(self.rawValue)"
    }
    
    var gridColumns: Int {
        switch numberOfPairs {
        case 6: return 3
        case 8: return 4
        case 10: return 4
        default: return 4
        }
    }
    
    var cardHeight: CGFloat {
        switch numberOfPairs {
        case 6: return 120
        case 8: return 100
        case 10: return 90
        default: return 90
        }
    }
} 
