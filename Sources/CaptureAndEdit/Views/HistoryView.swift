import SwiftUI
import AppKit

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 0) {
            headerView

            if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            }

            if viewModel.items.isEmpty {
                emptyStateView
            } else {
                historyGridView
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }

    private var headerView: some View {
        HStack {
            Text(L10n.historyTitle)
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()

            if !viewModel.items.isEmpty {
                Button(action: {
                    showDeleteAllConfirmation()
                }) {
                    Label(L10n.historyDeleteAll, systemImage: "trash")
                        .foregroundColor(.red)
                }
            }

            Button(action: {
                dismiss()
            }) {
                Label(L10n.close, systemImage: "xmark.circle")
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }

    private func errorView(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
            Text(message)
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.1))
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            Text(L10n.historyEmpty)
                .font(.title3)
                .foregroundColor(.secondary)
            Text(L10n.historyEmptyDescription)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var historyGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.items) { item in
                    HistoryItemCard(
                        item: item,
                        onCopy: {
                            if viewModel.copyToClipboard(item) {
                                showCopySuccessNotification()
                            }
                        },
                        onDelete: {
                            viewModel.deleteItem(item)
                        }
                    )
                }
            }
            .padding()
        }
    }

    private func showDeleteAllConfirmation() {
        let alert = NSAlert()
        alert.messageText = L10n.historyDeleteAllTitle
        alert.informativeText = L10n.historyDeleteAllMessage
        alert.alertStyle = .warning
        alert.addButton(withTitle: L10n.delete)
        alert.addButton(withTitle: L10n.cancel)

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            viewModel.deleteAll()
        }
    }

    private func showCopySuccessNotification() {
        print("✅ Copied to clipboard")
    }
}

struct HistoryItemCard: View {
    let item: HistoryItem
    let onCopy: () -> Void
    let onDelete: () -> Void

    @State private var thumbnail: NSImage?
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                thumbnailView

                if isHovered {
                    HStack(spacing: 4) {
                        Button(action: onCopy) {
                            Image(systemName: "doc.on.clipboard")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help(L10n.historyCopyToClipboard)

                        Button(action: {
                            showDeleteConfirmation()
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help(L10n.delete)
                    }
                    .padding(8)
                }
            }

            timestampView
        }
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .shadow(radius: isHovered ? 4 : 2)
        .onHover { hovering in
            isHovered = hovering
        }
        .onAppear {
            loadThumbnail()
        }
    }

    private var thumbnailView: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(nsImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        ProgressView()
                    )
                    .cornerRadius(6)
            }
        }
    }

    private var timestampView: some View {
        Text(formattedTimestamp)
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
    }

    private var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        // Use system locale for date formatting
        return formatter.string(from: item.timestamp)
    }

    private func loadThumbnail() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let image = NSImage(contentsOfFile: item.filePath) {
                DispatchQueue.main.async {
                    self.thumbnail = image
                }
            }
        }
    }

    private func showDeleteConfirmation() {
        let alert = NSAlert()
        alert.messageText = L10n.historyDeleteTitle
        alert.informativeText = L10n.historyDeleteMessage
        alert.alertStyle = .warning
        alert.addButton(withTitle: L10n.delete)
        alert.addButton(withTitle: L10n.cancel)

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            onDelete()
        }
    }
}
