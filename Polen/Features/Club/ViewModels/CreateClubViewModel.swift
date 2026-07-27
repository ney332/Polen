import Foundation
import Observation

@MainActor
@Observable
final class CreateClubViewModel {
    var draft = CreateClubDraft()
    var currentStep: CreateClubStep = .name
    var bookSearchQuery = ""
    var bookSearchState: BookSearchState = .idle
    var bookSearchResults: [Book] = []
    var errorMessage: String?
    var isSavingClub = false

    private let appState: AppState
    private let router: AppRouter
    private let createClubUseCase: CreateClubUseCase
    private let searchGoogleBooksUseCase: SearchGoogleBooksUseCase
    private let saveSelectedBookMetadataUseCase: SaveSelectedBookMetadataUseCase

    var canGoBack: Bool {
        currentStep.rawValue > 0
    }

    var isLastStep: Bool {
        currentStep == .review
    }

    var progressText: String {
        "\(currentStep.rawValue + 1) de \(CreateClubStep.allCases.count)"
    }

    var invitePreview: String {
        InviteCodeGenerator.makeCode(from: draft.name.isEmpty ? "POLEN" : draft.name)
    }

    init(
        appState: AppState,
        router: AppRouter,
        bookRepository: BookRepository,
        clubRepository: BookClubRepository
    ) {
        self.appState = appState
        self.router = router
        self.createClubUseCase = CreateClubUseCase(clubRepository: clubRepository)
        self.searchGoogleBooksUseCase = SearchGoogleBooksUseCase(bookRepository: bookRepository)
        self.saveSelectedBookMetadataUseCase = SaveSelectedBookMetadataUseCase(bookRepository: bookRepository)
    }

    func searchBooks() async {
        errorMessage = nil

        guard !bookSearchQuery.trimmed.isEmpty else {
            bookSearchResults = []
            bookSearchState = .idle
            return
        }

        bookSearchState = .loading

        do {
            let books = try await searchGoogleBooksUseCase.execute(query: bookSearchQuery)
            bookSearchResults = books
            bookSearchState = books.isEmpty ? .empty : .loaded
        } catch {
            bookSearchResults = []
            bookSearchState = .failed(error.localizedDescription)
        }
    }

    func selectBook(_ book: Book) {
        draft.selectedBook = book

        Task {
            do {
                try await saveSelectedBookMetadataUseCase.execute(book: book)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func addInvite(email: String) {
        let value = email.trimmed

        guard !value.isEmpty, !draft.invitedMembers.contains(value) else {
            return
        }

        draft.invitedMembers.append(value)
    }

    func removeInvite(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            draft.invitedMembers.remove(at: index)
        }
    }

    func goBack() {
        errorMessage = nil

        guard let previousStep = CreateClubStep(rawValue: currentStep.rawValue - 1) else {
            return
        }

        currentStep = previousStep
    }

    func continueFlow() {
        errorMessage = nil

        guard !isSavingClub else {
            return
        }

        guard validateCurrentStep() else {
            return
        }

        if isLastStep {
            finish()
            return
        }

        guard let nextStep = CreateClubStep(rawValue: currentStep.rawValue + 1) else {
            return
        }

        currentStep = nextStep
    }

    private func validateCurrentStep() -> Bool {
        switch currentStep {
        case .name:
            guard !draft.name.trimmed.isEmpty else {
                errorMessage = ClubFlowError.missingClubName.localizedDescription
                return false
            }
        case .book:
            guard draft.selectedBook != nil else {
                errorMessage = ClubFlowError.missingBook.localizedDescription
                return false
            }
        case .photo, .invite, .review:
            break
        }

        return true
    }

    private func finish() {
        guard let userID = appState.currentUser?.id else {
            errorMessage = ClubFlowError.missingAuthenticatedUser.localizedDescription
            return
        }

        isSavingClub = true

        Task {
            defer {
                isSavingClub = false
            }

            do {
                let club = try await createClubUseCase.execute(draft: draft, ownerID: userID)
                appState.enterClub(id: club.id)
                router.popToRoot()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
