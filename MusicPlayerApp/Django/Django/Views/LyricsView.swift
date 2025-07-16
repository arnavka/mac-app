import SwiftUI

struct LyricsView: View {
    @ObservedObject var viewModel: LyricsViewModel
    @State private var triggerRender: Int = 0 // 💥 dummy state to force UI refresh

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.lyrics.indices, id: \.self) { index in
                        Text(viewModel.lyrics[index].text)
                            .font(index == viewModel.currentLineIndex ? .headline : .body)
                            .foregroundColor(index == viewModel.currentLineIndex ? .blue : .primary)
                            .id(index)
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.currentLineIndex) {
                triggerRender += 1 // 💥 this will force re-render
                withAnimation(.easeInOut(duration: 0.4)) {
                    print("🌀 Scrolling to line: \(viewModel.currentLineIndex)")
                    proxy.scrollTo(viewModel.currentLineIndex, anchor: .center)
                }
            }
        }
        .frame(maxHeight: 200)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
