import Foundation

struct CreateClubDraft: Equatable {
    var name = ""
    var photoSymbolName = "person.3.fill"
    var selectedBook: Book?
    var invitedMembers: [String] = []
}
