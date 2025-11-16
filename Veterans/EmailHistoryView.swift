import SwiftUI
import SwiftData

struct EmailHistoryView: View {
    let veteran: Veteran
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var emailLogs: [EmailLog]
    
    var veteranEmails: [EmailLog] {
        emailLogs.filter { $0.veteran?.id == veteran.id }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Email History")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(veteranEmails.count) email\(veteranEmails.count == 1 ? "" : "s")")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.regularMaterial)
            .overlay(
                Rectangle()
                    .fill(.primary.opacity(0.1))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Content
            if veteranEmails.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(veteranEmails, id: \.id) { emailLog in
                            EmailHistoryRow(emailLog: emailLog)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .frame(minWidth: 800, idealWidth: 1000, maxWidth: 1200)
        .frame(minHeight: 500, idealHeight: 700, maxHeight: 900)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "envelope")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Email History")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text("No emails have been sent to this veteran yet.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Email History Row

struct EmailHistoryRow: View {
    let emailLog: EmailLog
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(emailLog.subject)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(emailLog.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status Badge
                HStack(spacing: 6) {
                    Image(systemName: emailLog.status.icon)
                        .font(.system(size: 12, weight: .medium))
                    Text(emailLog.status.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(Color(emailLog.status.color))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(emailLog.status.color).opacity(0.1))
                )
            }
            
            // Recipients
            HStack(spacing: 8) {
                Image(systemName: "person.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text(emailLog.recipients.joined(separator: ", "))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Error message if failed
            if let errorMessage = emailLog.errorMessage, !errorMessage.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                    
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                        .lineLimit(3)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.red.opacity(0.1))
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isHovered ? .blue.opacity(0.3) : .clear, lineWidth: 2)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
