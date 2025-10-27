Here's a comprehensive markdown template you can paste into Cursor to guide it toward building a modern macOS UI for your Veterans Claims Foundation app:

---

```markdown
# macOS UI/UX Design Guidelines for Veterans Claims Foundation App

## Design Philosophy
- Follow **macOS Human Interface Guidelines** with native controls and patterns
- Use **Big Sur/Monterey design language** with proper spacing, rounded corners, and depth
- Implement **glass morphism effects** and system colors for modern aesthetic
- Ensure **visual hierarchy** through typography, spacing, and contrast

## Typography Standards
- **Large Title**: `.font(.largeTitle)` for main headings
- **Title**: `.font(.title)` or `.font(.title2)` for section headers  
- **Headline**: `.font(.headline)` for form labels and important text
- **Body**: `.font(.body)` for standard content
- **Caption**: `.font(.caption)` for secondary information
- Always use **San Francisco font** (system default)

## Color Palette
Use **semantic system colors** that adapt to light/dark mode:
- Primary backgrounds: `Color(.controlBackgroundColor)`
- Secondary backgrounds: `Color(.windowBackgroundColor)`
- Text colors: `Color.primary`, `Color.secondary`
- Accent colors: `Color.accentColor` or custom `.blue`, `.green`
- Subtle separators: `Color(.separatorColor)`

## Spacing System
- **Extra Small**: 4pt
- **Small**: 8pt  
- **Medium**: 16pt (default padding)
- **Large**: 24pt
- **Extra Large**: 32pt
- Use `.padding()` with specific values: `.padding(.horizontal, 16)`

## Component Styling

### Forms and Inputs
```
Form {
    Section(header: Text("Personal Information")) {
        TextField("First Name", text: $firstName)
            .textFieldStyle(.roundedBorder)
        
        DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
            .datePickerStyle(.compact)
    }
}
.formStyle(.grouped)
.padding()
```

### Buttons
```
Button("Save Veteran") {
    saveAction()
}
.buttonStyle(.borderedProminent)
.controlSize(.large)
.padding()
```

### Lists and Sidebars
```
List(veterans) { veteran in
    NavigationLink(destination: VeteranDetailView(veteran: veteran)) {
        VeteranRow(veteran: veteran)
    }
}
.listStyle(.sidebar)
```

### Containers with Depth
```
VStack(spacing: 16) {
    // Content here
}
.padding(24)
.background(.ultraThinMaterial)
.cornerRadius(12)
.shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
```

## Layout Patterns

### NavigationSplitView (Three-Column)
```
NavigationSplitView {
    // Sidebar
    List(selection: $selectedSection) {
        Label("Veterans", systemImage: "person.3")
        Label("Claims", systemImage: "doc.text")
        Label("Dashboard", systemImage: "chart.bar")
    }
    .navigationTitle("Veterans Claims Foundation")
} content: {
    // Middle column (list of items)
    List(veterans) { veteran in
        NavigationLink(value: veteran) {
            VeteranRow(veteran: veteran)
        }
    }
    .navigationTitle("Veterans")
} detail: {
    // Detail view
    VeteranDetailView()
}
```

### Toolbar
```
.toolbar {
    ToolbarItem(placement: .navigation) {
        Button(action: toggleSidebar) {
            Label("Toggle Sidebar", systemImage: "sidebar.left")
        }
    }
    
    ToolbarItem(placement: .primaryAction) {
        Button(action: addVeteran) {
            Label("Add Veteran", systemImage: "plus")
        }
        .buttonStyle(.borderedProminent)
    }
}
```

## Visual Effects

### Glass Morphism
```
.background(.thinMaterial)  // or .ultraThinMaterial, .regularMaterial
```

### Rounded Corners
```
.cornerRadius(12)  // Standard: 8-12pt
```

### Shadows
```
.shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
```

### Hover Effects
```
.buttonStyle(.plain)
.onHover { hovering in
    // Custom hover behavior
}
```

## Icons and SF Symbols
- Use **SF Symbols** for all icons: `systemImage: "person.fill"`
- Standard icon sizes: `.font(.system(size: 16))` to `.font(.system(size: 24))`
- Color icons with `.foregroundColor(.accentColor)`

Common symbols for Veterans app:
- `person.3` - Veterans list
- `doc.text` - Claims/documents
- `chart.bar` - Dashboard/statistics
- `folder` - File management
- `checkmark.circle` - Approved/completed
- `exclamationmark.triangle` - Warnings

## Responsive Sizing
```
.frame(minWidth: 300, idealWidth: 400, maxWidth: .infinity, 
       minHeight: 200, idealHeight: 400, maxHeight: .infinity)
```

## Accessibility
- Use `.accessibilityLabel()` for all interactive elements
- Ensure color contrast ratios meet WCAG standards
- Support **Dynamic Type** by using system fonts
- Test with **VoiceOver** enabled

## Animation
```
withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
    // State change
}
```

## Dark Mode Support
All colors and materials automatically adapt when using:
- System colors (`Color.primary`, `Color.secondary`)
- Materials (`.ultraThinMaterial`)
- Semantic colors (`Color(.controlBackgroundColor)`)

## Example: Modern Form Card
```
VStack(alignment: .leading, spacing: 16) {
    Text("Add Veteran")
        .font(.title2)
        .fontWeight(.bold)
    
    Divider()
    
    Form {
        Section("Personal Information") {
            TextField("First Name", text: $firstName)
            TextField("Last Name", text: $lastName)
            DatePicker("Date of Birth", selection: $dateOfBirth)
        }
        
        Section("Service Information") {
            Picker("Branch", selection: $branch) {
                Text("Army").tag("Army")
                Text("Navy").tag("Navy")
                Text("Marines").tag("Marines")
                Text("Air Force").tag("Air Force")
            }
            TextField("Rank at Separation", text: $rank)
        }
    }
    .formStyle(.grouped)
    
    HStack {
        Spacer()
        Button("Cancel") {
            dismiss()
        }
        .buttonStyle(.bordered)
        
        Button("Save") {
            saveVeteran()
        }
        .buttonStyle(.borderedProminent)
    }
}
.padding(24)
.frame(width: 500)
.background(.ultraThinMaterial)
.cornerRadius(16)
.shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
```

## When Generating Code:
1. **Always apply proper spacing** (minimum 16pt padding on containers)
2. **Use system colors and materials** (never hardcoded colors)
3. **Include SF Symbols** for visual interest
4. **Add proper visual hierarchy** through font weights and sizes
5. **Implement hover states** and button styles
6. **Use NavigationSplitView** for multi-pane layouts
7. **Add subtle shadows and corner radius** to cards and containers
8. **Support both light and dark mode** automatically
9. **Follow macOS window chrome patterns** with proper toolbars
10. **Test all interactive states** (pressed, hovered, disabled)

## References
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)
- [SF Symbols Browser](https://developer.apple.com/sf-symbols/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
```



[1](https://developer.apple.com/documentation/swiftui)
[2](https://developer.apple.com/documentation/clockkit/swiftui-templates)
[3](https://www.reddit.com/r/swift/comments/ljl6bq/we_were_so_frustrated_by_apple_docs_that_we_made/)
[4](https://wwdcnotes.com/documentation/wwdcnotes/wwdc23-10115-design-with-swiftui/)
[5](https://swift.org/getting-started/swiftui/)
[6](https://codia.ai/es/blog/swiftui-ui-layout-introduction)
[7](https://developer.apple.com/videos/play/wwdc2023/10115/)
[8](https://eclecticlight.co/2024/05/16/swiftui-on-macos-documents/)
[9](https://www.figma.com/community/file/864234074226183072/swiftui-input-kit)
[10](https://developer.apple.com/design/tips/)
[11](https://designcode.io/cursor-create-your-first-macos-app/)

***