import SwiftUI

struct ContentView: View {
    @StateObject var recordingManager = AudioRecorder()
    @State private var isUploading = false
    
    var body: some View {
        VStack   {
            VStack {
                if !isUploading {
                    if recordingManager.isRecording {
                        Button("Stop Recording") {
                            recordingManager.stopRecording()
                            isUploading = true
                        }
                    } else {
                        Button("Start Recording") {
                            recordingManager.startRecording()
                        }
                    }
                } else {
                    Button("Processing...") {
                        
                    }.disabled(true)
                }
            }
            VStack {
                if recordingManager.isRecording || isUploading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.bottom)
                } else {
                    Spacer()
                }
            }.frame(height: 50)
        }
        .onChange(of: recordingManager.isRecording) { newValue in
            if !newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Adjust delay as needed
                    isUploading = false
                }
            }
        }
    }
}
