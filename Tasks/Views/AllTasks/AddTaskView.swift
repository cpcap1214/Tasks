//
//  AddTaskView.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/23.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    
    let onSave: (String, String?, TaskPriority, Date?) -> Void
    let initialTask: Task?
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .normal
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    
    private var isEditing: Bool {
        initialTask != nil
    }
    
    private var canSave: Bool {
        !title.trimmed.isEmpty
    }
    
    init(onSave: @escaping (String, String?, TaskPriority, Date?) -> Void, editingTask: Task? = nil) {
        self.onSave = onSave
        self.initialTask = editingTask
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 8) {
                        Text(isEditing ? "編輯任務" : "新增任務")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(isEditing ? "修改任務詳細資訊" : "建立你的下一個目標")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 20) {
                        // Title Section
                        ModernInputSection(
                            title: "任務標題",
                            subtitle: "簡潔描述你要完成什麼",
                            isRequired: true
                        ) {
                            ModernTextField(
                                placeholder: "例如：完成項目提案",
                                text: $title
                            )
                        }
                        
                        // Description Section  
                        ModernInputSection(
                            title: "詳細描述",
                            subtitle: "可選：補充任務的具體內容或註記"
                        ) {
                            ModernTextEditor(
                                placeholder: "例如：準備投影片，包含市場分析和財務預測...",
                                text: $description
                            )
                        }
                        
                        // Priority Section
                        ModernInputSection(
                            title: "優先級",
                            subtitle: "設定這個任務的重要程度"
                        ) {
                            PrioritySelector(selectedPriority: $priority)
                        }
                        
                        // Due Date Section
                        ModernInputSection(
                            title: "截止日期",
                            subtitle: "設定完成期限以便安排時間"
                        ) {
                            VStack(spacing: 16) {
                                DueDateToggle(hasDueDate: $hasDueDate)
                                
                                if hasDueDate {
                                    ModernDatePicker(selectedDate: $dueDate)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .safeAreaInset(edge: .bottom) {
                // Action Buttons
                VStack(spacing: 12) {
                    // Save Button
                    Button(action: saveTask) {
                        Text(isEditing ? "更新任務" : "建立任務")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canSave ? Color.black : Color.gray.opacity(0.3))
                            .cornerRadius(12)
                    }
                    .disabled(!canSave)
                    
                    // Cancel Button
                    Button(action: { dismiss() }) {
                        Text("取消")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
                .background(Color(.systemGroupedBackground))
            }
        }
        .onAppear {
            if let task = initialTask {
                loadTaskData(task)
            }
        }
    }
    
    private func loadTaskData(_ task: Task) {
        title = task.title
        description = task.description ?? ""
        priority = task.priority
        hasDueDate = task.dueDate != nil
        if let taskDueDate = task.dueDate {
            dueDate = taskDueDate
        }
    }
    
    private func saveTask() {
        let finalDescription = description.trimmed.isEmpty ? nil : description.trimmed
        let finalDueDate = hasDueDate ? dueDate : nil
        
        onSave(title.trimmed, finalDescription, priority, finalDueDate)
        dismiss()
    }
    
    private func priorityColor(for priority: TaskPriority) -> Color {
        switch priority {
        case .low:
            return Color.green
        case .normal:
            return Color.blue
        case .high:
            return Color.yellow
        case .urgent:
            return AppConstants.Colors.destructive
        }
    }
}

// MARK: - Supporting Views

struct ModernInputSection<Content: View>: View {
    let title: String
    let subtitle: String
    let isRequired: Bool
    let content: Content
    
    init(title: String, subtitle: String, isRequired: Bool = false, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.isRequired = isRequired
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if isRequired {
                        Text("*")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.red)
                    }
                }
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            content
        }
    }
}

struct ModernTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 16))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

struct ModernTextEditor: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
            }
            
            TextEditor(text: $text)
                .font(.system(size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct PrioritySelector: View {
    @Binding var selectedPriority: TaskPriority
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(TaskPriority.allCases, id: \.self) { priority in
                PriorityOptionRow(
                    priority: priority,
                    isSelected: selectedPriority == priority,
                    onTap: { selectedPriority = priority }
                )
            }
        }
        .padding(.vertical, 4)
    }
}

struct PriorityOptionRow: View {
    let priority: TaskPriority
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Priority Indicator
                Circle()
                    .fill(priorityColor(for: priority))
                    .frame(width: 16, height: 16)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(priority.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(priorityDescription(for: priority))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .blue : .gray.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private func priorityColor(for priority: TaskPriority) -> Color {
        switch priority {
        case .low: return .green
        case .normal: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
    
    private func priorityDescription(for priority: TaskPriority) -> String {
        switch priority {
        case .low: return "可以稍後處理"
        case .normal: return "標準任務"
        case .high: return "需要優先完成"
        case .urgent: return "立即處理"
        }
    }
}

struct DueDateToggle: View {
    @Binding var hasDueDate: Bool
    
    var body: some View {
        Button(action: { hasDueDate.toggle() }) {
            HStack(spacing: 16) {
                Image(systemName: hasDueDate ? "calendar.circle.fill" : "calendar.circle")
                    .font(.system(size: 20))
                    .foregroundColor(hasDueDate ? .blue : .gray.opacity(0.6))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("設定截止日期")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(hasDueDate ? "已設定日期提醒" : "無截止日期")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $hasDueDate)
                    .toggleStyle(SwitchToggleStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct ModernDatePicker: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        DatePicker(
            "選擇日期",
            selection: $selectedDate,
            in: Date()...,
            displayedComponents: [.date]
        )
        .datePickerStyle(.compact)
        .font(.system(size: 16))
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    AddTaskView(
        onSave: { title, description, priority, dueDate in
            print("Task: \(title), \(String(describing: description)), \(priority), \(String(describing: dueDate))")
        }
    )
}