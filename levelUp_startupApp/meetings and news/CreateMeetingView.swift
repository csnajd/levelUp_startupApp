import SwiftUI

struct CreateMeetingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: manViewModel
    
    @State private var meetingName = ""
    @State private var selectedProject = ""
    @State private var selectedAttendees: [String] = []
    @State private var selectedDate = Date()
    @State private var platform = ""
    @State private var link = ""
    
    @State private var showProjectPicker = false
    @State private var showAttendeePicker = false
    @State private var showDatePicker = false
    @State private var showPlatformPicker = false
    
    var isFormValid: Bool {
        !meetingName.isEmpty && !selectedProject.isEmpty && !platform.isEmpty && !link.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Create New Meeting")
                        .font(.system(size: 28, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    
                    // Meeting Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meeting Name")
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("e.g. Fajer company", text: $meetingName)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color("primary"), lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, 24)
                    
                    // Project
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Project")
                            .font(.system(size: 16, weight: .medium))
                        
                        Button(action: {
                            showProjectPicker = true
                        }) {
                            HStack {
                                Text(selectedProject.isEmpty ? "Select project" : selectedProject)
                                    .foregroundColor(selectedProject.isEmpty ? .gray : .black)
                                
                                Spacer()
                                
                                Text("select")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color("primary"))
                                    .cornerRadius(16)
                            }
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color("primary"), lineWidth: 2)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Who can join
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Who can join")
                            .font(.system(size: 16, weight: .medium))
                        
                        Button(action: {
                            showAttendeePicker = true
                        }) {
                            HStack {
                                if selectedAttendees.isEmpty {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.gray)
                                } else {
                                    HStack(spacing: -10) {
                                        ForEach(0..<min(selectedAttendees.count, 3), id: \.self) { _ in
                                            Circle()
                                                .fill(Color("primary"))
                                                .frame(width: 28, height: 28)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: 2)
                                                )
                                        }
                                        if selectedAttendees.count > 3 {
                                            Text("+\(selectedAttendees.count - 3)")
                                                .font(.system(size: 12))
                                                .foregroundColor(.black)
                                                .padding(.leading, 8)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                Text("select")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color("primary"))
                                    .cornerRadius(16)
                            }
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color("primary"), lineWidth: 2)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Time and Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time and Date")
                            .font(.system(size: 16, weight: .medium))
                        
                        Button(action: {
                            showDatePicker = true
                        }) {
                            HStack {
                                Text(formatDate(selectedDate))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("select")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color("primary"))
                                    .cornerRadius(16)
                            }
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color("primary"), lineWidth: 2)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Meeting platform
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meeting paltform")
                            .font(.system(size: 16, weight: .medium))
                        
                        Button(action: {
                            showPlatformPicker = true
                        }) {
                            HStack {
                                Text(platform.isEmpty ? "e.g. Zoom" : platform)
                                    .foregroundColor(platform.isEmpty ? .gray : .black)
                                
                                Spacer()
                                
                                Text("select")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color("primary"))
                                    .cornerRadius(16)
                            }
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color("primary"), lineWidth: 2)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Link
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Link")
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("URL", text: $link)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color("primary"), lineWidth: 2)
                            )
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    }
                    .padding(.horizontal, 24)
                    
                    // Create Button
                    Button(action: {
                        createMeeting()
                    }) {
                        Text("Create New Meeting")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isFormValid ? Color("primary") : Color.gray)
                            .cornerRadius(28)
                    }
                    .disabled(!isFormValid)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
            .sheet(isPresented: $showProjectPicker) {
                ProjectPickerView(selectedProject: $selectedProject)
            }
            .sheet(isPresented: $showAttendeePicker) {
                AttendeePickerView(selectedAttendees: $selectedAttendees)
            }
            .sheet(isPresented: $showDatePicker) {
                DatePickerView(selectedDate: $selectedDate)
            }
            .sheet(isPresented: $showPlatformPicker) {
                PlatformPickerView(selectedPlatform: $platform)
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy | hh:mm a"
        return formatter.string(from: date)
    }
    
    func createMeeting() {
        let meeting = Meeting(
            name: meetingName,
            projectID: "project1",
            projectName: selectedProject,
            attendeeIDs: selectedAttendees,
            dateTime: selectedDate,
            platform: platform,
            link: link,
            communityID: "community1",
            createdAt: Date()
        )
        
        viewModel.addMeeting(meeting)
        dismiss()
    }
}

// Project Picker
struct ProjectPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedProject: String
    
    let projects = ["The line project", "Counting project", "Design project", "Marketing project"]
    
    var body: some View {
        NavigationStack {
            List(projects, id: \.self) { project in
                Button(action: {
                    selectedProject = project
                    dismiss()
                }) {
                    HStack {
                        Text(project)
                        Spacer()
                        if selectedProject == project {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color("primary"))
                        }
                    }
                }
            }
            .navigationTitle("Select Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// Attendee Picker
struct AttendeePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAttendees: [String]
    
    let attendees = ["user1", "user2", "user3", "user4", "user5"]
    
    var body: some View {
        NavigationStack {
            List(attendees, id: \.self) { attendee in
                Button(action: {
                    if selectedAttendees.contains(attendee) {
                        selectedAttendees.removeAll { $0 == attendee }
                    } else {
                        selectedAttendees.append(attendee)
                    }
                }) {
                    HStack {
                        Text("User \(attendee)")
                        Spacer()
                        if selectedAttendees.contains(attendee) {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color("primary"))
                        }
                    }
                }
            }
            .navigationTitle("Select Attendees")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// Date Picker
struct DatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker("Select Date and Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date & Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// Platform Picker
struct PlatformPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPlatform: String
    
    let platforms = ["Zoom", "Webex", "Google Meet", "Microsoft Teams"]
    
    var body: some View {
        NavigationStack {
            List(platforms, id: \.self) { platform in
                Button(action: {
                    selectedPlatform = platform
                    dismiss()
                }) {
                    HStack {
                        Text(platform)
                        Spacer()
                        if selectedPlatform == platform {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color("primary"))
                        }
                    }
                }
            }
            .navigationTitle("Select Platform")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    CreateMeetingView(viewModel: manViewModel())
}