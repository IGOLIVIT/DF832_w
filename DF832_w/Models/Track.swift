import Foundation

struct Track: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let accentColorName: String
    let secondaryAccentColorName: String
    let recommendedDrillIDs: [String]
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
}

enum TrackID: String, CaseIterable {
    case focus = "focus"
    case body = "body"
    case mind = "mind"
    case order = "order"
}
