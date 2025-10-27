import SwiftUI
import SwiftData

struct EmailHistoryView: View {
    let veteran: Veteran
    @Environment(\.dismiss) private var dismiss
    @Query private var emailLogs: [EmailLog]
    
    var veteranEmails: [EmailLog] {
        emailLogs.filter { $0.veteran?.id == veteran.id }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(veteranEmails, id: \.id) { emailLog in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(emailLog.subject)
                                .font(.headline)
                            Spacer()
                            Text(emailLog.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Image(systemName: emailLog.status.icon)
                                .foregroundColor(Color(emailLog.status.color))
                            Text(emailLog.status.rawValue)
                                .font(.caption)
                                .foregroundColor(Color(emailLog.status.color))
                            
                            Spacer()
                            
                            Text(emailLog.recipients.joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Email History")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
