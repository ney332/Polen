import AVFoundation
import Observation
import SwiftUI

struct AudioPlaybackView: View {
    let audioData: Data
    let duration: TimeInterval?

    @State private var player = AudioPlayerController()

    var body: some View {
        HStack(spacing: PollenSpacing.small) {
            Button {
                player.togglePlayback(data: audioData)
            } label: {
                Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(player.isPlaying ? "Pausar audio" : "Tocar audio")

            Text(durationText)
                .font(PollenTypography.caption)
                .foregroundStyle(PollenColors.textSecondary)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, PollenSpacing.small)
        .padding(.vertical, PollenSpacing.xSmall)
        .background(PollenColors.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var durationText: String {
        let totalSeconds = Int((duration ?? 0).rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

@MainActor
@Observable
private final class AudioPlayerController {
    var isPlaying = false

    private var player: AVAudioPlayer?

    func togglePlayback(data: Data) {
        if isPlaying {
            player?.pause()
            isPlaying = false
            return
        }

        do {
            if player == nil {
                player = try AVAudioPlayer(data: data)
                player?.prepareToPlay()
            }

            player?.play()
            isPlaying = true
        } catch {
            isPlaying = false
        }
    }
}
