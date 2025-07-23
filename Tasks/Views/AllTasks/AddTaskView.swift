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
            Form {
                Section(header: Text("Task Details")) {
                    // Title
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Title")
                            .font(AppConstants.Fonts.smallLabel)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                        
                        TextField("Enter task title", text: $title)
                            .font(AppConstants.Fonts.primaryContent)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.vertical, 4)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description (Optional)")
                            .font(AppConstants.Fonts.smallLabel)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                        
                        TextField("Enter description", text: $description, axis: .vertical)
                            .font(AppConstants.Fonts.secondaryContent)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priorityColor(for: priority))
                                    .frame(width: 12, height: 12)
                                
                                Text(priority.displayName)
                                    .font(AppConstants.Fonts.secondaryContent)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Due Date")) {
                    Toggle("Set due date", isOn: $hasDueDate)
                        .font(AppConstants.Fonts.secondaryContent)
                    
                    if hasDueDate {
                        DatePicker("Due date", selection: $dueDate, displayedComponents: [.date])
                            .font(AppConstants.Fonts.secondaryContent)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppConstants.Colors.secondaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Update" : "Save") {
                        saveTask()
                    }
                    .disabled(!canSave)
                    .foregroundColor(canSave ? AppConstants.Colors.accent : AppConstants.Colors.secondaryText)
                }
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

// MARK: - Preview

#Preview {
    AddTaskView(
        onSave: { title, description, priority, dueDate in
            print("Task: \(title), \(String(describing: description)), \(priority), \(String(describing: dueDate))")
        }
    )
}