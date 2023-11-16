//
//  ContentView.swift
//  humane Watch App
//
//  Created by Olivia Li on 11/15/23.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var isRecording = false
    private var audioRecorder: AVAudioRecorder?

    init() {
        setupAudioRecorder()
    }

    var body: some View {
        VStack {
            if isRecording {
                Button("Stop Recording", action: {
                    stopRecording()
                    uploadAudioFile()
                })
            } else {
                Button("Start Recording", action: startRecording)
            }
        }
    }

    private mutating func setupAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playAndRecord, mode: .default)
        try? audioSession.setActive(true)

        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
        } catch {
            // Handle error
        }
    }

    private func startRecording() {
        guard let audioRecorder = audioRecorder, !audioRecorder.isRecording else { return }
        audioRecorder.record()
        isRecording = true
    }

    private func stopRecording() {
        guard let audioRecorder = audioRecorder, audioRecorder.isRecording else { return }
        audioRecorder.stop()
        isRecording = false
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func uploadAudioFile() {
            guard let audioURL = audioRecorder?.url else { return }
            
            let url = URL(string: "http://192.168.86.82:3000/upload")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var data = Data()

            // Append audio data
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(audioURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
            if let audioData = try? Data(contentsOf: audioURL) {
                data.append(audioData)
            }
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

            // URLSession upload task
            let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
                if let error = error {
                    // Handle error
                    print("Upload error: \(error)")
                    return
                }
                // Handle response here
            }
            task.resume()
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
