import SwiftUI
import UIKit

struct AuthorAvatarView: View {
    let imageData: Data?
    let symbolName: String?
    let size: CGFloat

    var body: some View {
        Group {
            if let imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: symbolName ?? "person.crop.circle.fill")
                    .font(.system(size: size * 0.54, weight: .semibold))
                    .foregroundStyle(PollenColors.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(PollenColors.background)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
