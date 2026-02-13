//
//  CreateMeetingView.swift
//  levelUp_startupApp
//
//  Created by Ghala Alsalem on 10/02/2026.
//


import SwiftUI
import CloudKit

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
    
    // TODO: Replace with actual community ID from your app state
    var currentCommunityID: String {
        return "community1" // Replace this with actual community ID
    }
    
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
                        
                        TextField("e.g. WorkHive Meeting", text: $meetingName)
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
                AttendeePickerView(
                    selectedAttendees: $selectedAttendees,
                    communityID: currentCommunityID
                )
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
            projectID: "project1", // TODO: Get actual project ID from your project picker
            projectName: selectedProject,
            attendeeIDs: selectedAttendees,
            dateTime: selectedDate,
            platform: platform,
            link: link,
            communityID: currentCommunityID,
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
    
    // ✅ Only show "Not related to any project" by default
    // Later: fetch real projects from CloudKit
    let projects = ["Not related to any project"]
    
    var body: some View {
        NavigationStack {
            List(projects, id: \.self) { project in
                Button(action: {
                    selectedProject = project
                    dismiss()
                }) {
                    HStack {
                        Text(project)
                            .foregroundColor(project == "Not related to any project" ? .gray : .primary)
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
                        .foregroundColor(Color("primary"))
                }
            }
        }
    }
}

// ✅ UPDATED - Attendee Picker with CloudKit Integration
struct AttendeePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAttendees: [String]
    
    @State private var communityMembers: [User] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var communityID: String
    private let cloudKitService = CloudKitServices.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading members...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        Text("Error Loading Members")
                            .font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Retry") {
                            Task {
                                await loadCommunityMembers()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("primary"))
                    }
                    .padding()
                } else if communityMembers.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No community members found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Invite people to join your community")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(communityMembers) { member in
                            Button(action: {
                                toggleMember(member.id)
                            }) {
                                HStack(spacing: 12) {
                                    // Profile image or placeholder
                                    if let image = member.profileImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .fill(Color("primary").opacity(0.2))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Text(member.givenName.prefix(1).uppercased())
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(Color("primary"))
                                            )
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(member.fullName)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                        
                                        // Only show email if user has enabled it in privacy settings
                                        if !member.email.isEmpty && member.showEmail {
                                            Text(member.email)
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedAttendees.contains(member.id) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color("primary"))
                                            .font(.system(size: 24))
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.gray.opacity(0.3))
                                            .font(.system(size: 24))
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Show count of selected members
                        if !selectedAttendees.isEmpty {
                            Section {
                                HStack {
                                    Text("\(selectedAttendees.count) member\(selectedAttendees.count == 1 ? "" : "s") selected")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Button("Clear All") {
                                        selectedAttendees.removeAll()
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(Color("primary"))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Attendees")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !selectedAttendees.isEmpty && !communityMembers.isEmpty {
                        Button("Select All") {
                            selectedAttendees = communityMembers.map { $0.id }
                        }
                        .font(.subheadline)
                        .foregroundColor(Color("primary"))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("primary"))
                    .fontWeight(.semibold)
                }
            }
            .task {
                await loadCommunityMembers()
            }
        }
    }
    
    private func toggleMember(_ memberID: String) {
        if selectedAttendees.contains(memberID) {
            selectedAttendees.removeAll { $0 == memberID }
        } else {
            selectedAttendees.append(memberID)
        }
    }
    
    private func loadCommunityMembers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            communityMembers = try await cloudKitService.fetchCommunityMembers(communityID: communityID)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("❌ Error loading community members: \(error)")
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
