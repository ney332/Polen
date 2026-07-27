import Foundation

protocol IdentifierFactory {
    func makeID() -> UUID
}

struct UUIDIdentifierFactory: IdentifierFactory {
    func makeID() -> UUID {
        UUID()
    }
}
