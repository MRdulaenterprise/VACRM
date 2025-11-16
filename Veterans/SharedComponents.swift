//
//  SharedComponents.swift
//  Veterans
//
//  Created by Dagger4 on 10/26/25.
//

import SwiftUI

// MARK: - Enhanced Status Badge
struct StatusBadge: View {
    let status: String
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(status)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.regularMaterial)
                .overlay(
                    Capsule()
                        .stroke(statusColor.opacity(0.3), lineWidth: 1.5)
                )
        )
        .shadow(
            color: isHovered ? statusColor.opacity(0.3) : .black.opacity(0.05),
            radius: isHovered ? 6 : 3,
            x: 0,
            y: isHovered ? 3 : 1
        )
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    private var statusColor: Color {
        switch status.lowercased() {
        case "new":
            return .blue
        case "in progress", "inprogress":
            return .orange
        case "under review", "underreview":
            return .purple
        case "review of evidence":
            return .purple
        case "preparation for decision":
            return .purple
        case "pending decision approval":
            return .purple
        case "pending notification":
            return .purple
        case "complete", "completed":
            return .green
        case "approved":
            return .green
        case "closed":
            return .gray
        case "appealed":
            return .red
        case "denied":
            return .red
        default:
            return .secondary
        }
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
                
                Text("\(count)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.2), lineWidth: 1.5)
                )
        )
        .shadow(
            color: isHovered ? color.opacity(0.2) : .black.opacity(0.05),
            radius: isHovered ? 8 : 4,
            x: 0,
            y: isHovered ? 4 : 2
        )
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Collapsible Section
struct CollapsibleSection<Content: View>: View {
    let title: String
    let icon: String
    @Binding var isExpanded: Bool
    let content: Content
    
    init(title: String, icon: String, isExpanded: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self._isExpanded = isExpanded
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                    
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                content
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

