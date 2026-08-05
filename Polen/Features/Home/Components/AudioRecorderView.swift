import AVFoundation
import Observation
import SwiftUI

struct AudioRecorderView: View {
    @Binding var audioData: Data?
    @Binding var audioDuration: TimeInterval?

    @State private var recorder = AudioRecorderController()

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.xSmall) {
            if let audioData {
                HStack(spacing: PollenSpacing.small) {
                    AudioPlaybackView(
                        audioData: audioData,
                        duration: audioDuration
                    )

                    Button {
                        self.audioData = nil
                        audioDuration = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remover audio")
                }
            } else {
                HStack(spacing: PollenSpacing.small) {
                    Button {
                        Task {
                            if recorder.isRecording {
                                if let attachment = await recorder.stopRecording() {
                                    audioData = attachment.data
                                    audioDuration = attachment.duration
                                }
                            } else {
                                await recorder.startRecording()
                            }
                        }
                    } label: {
                        Label(
                            recorder.isRecording ? "Parar audio" : "Gravar audio",
                            systemImage: recorder.isRecording ? "stop.circle.fill" : "mic.circle.fill"
                        )
                    }
                    .buttonStyle(.bordered)

                    if recorder.isRecording {
                        Button("Cancelar") {
                            recorder.cancelRecording()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if let errorMessage = recorder.errorMessage {
                Text(errorMessage)
                    .font(PollenTypography.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

@MainActor
@Observable
private final class AudioRecorderController {
    var isRecording = false
    var errorMessage: String?

    private var recorder: AVAudioRecorder?
    private var recordingURL: URL?
    private var recordingStartedAt: Date?

    func startRecording() async {
        errorMessage = nil

        guard await requestPermission() else {
            errorMessage = "Permita o uso do microfone para gravar audio."
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker])
            try session.setActive(true)

            let url = FileManager.default.temporaryDirectory
                .appending(path: "polen-audio-\(UUID().uuidString).m4a")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
            ]

            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.record()
            self.recorder = recorder
            recordingURL = url
            recordingStartedAt = .now
            isRecording = true
        } catch {
            errorMessage = "Nao foi possivel iniciar a gravacao."
            isRecording = false
        }
    }

    func stopRecording() async -> AudioAttachment? {
        guard let recorder, let recordingURL else {
            return nil
        }

        recorder.stop()
        isRecording = false
        self.recorder = nil

        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            let data = try Data(contentsOf: recordingURL)
            let duration = max(Date().timeIntervalSince(recordingStartedAt ?? .now), 1)
            return AudioAttachment(data: data, duration: duration)
        } catch {
            errorMessage = "Nao foi possivel salvar o audio."
            return nil
        }
    }

    func cancelRecording() {
        recorder?.stop()
        recorder?.deleteRecording()
        recorder = nil
        recordingURL = nil
        recordingStartedAt = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func requestPermission() async -> Bool {
        if #available(iOS 17.0, *) {
            return await AVAudioApplication.requestRecordPermission()
        }

        return await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
