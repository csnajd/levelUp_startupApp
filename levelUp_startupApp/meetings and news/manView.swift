//
//  manView.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 02/02/2026.
//
import SwiftUI

struct manView: View {
    @StateObject private var viewModel = manViewModel()
    @State private var showCreateMeeting = false
    @State private var selectedTab = 1
    
    var body: some View {
        // ❌ REMOVE NavigationStack - it's already wrapped in HomepageView
        VStack(spacing: 0) {
            // Header - Simple version without "My Community"
            HStack {
                Text("Meetings")
                    .font(.system(size: 32, weight: .bold))
                
                Spacer()
                
                Button(action: {
                    showCreateMeeting = true
                }) {
                    HStack(spacing: 6) {
                        Text("New")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color("primary"))
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
            
            // Rest of your code stays the same...
            if viewModel.meetings.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("No meetings scheduled")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Text("Tap 'New +' to create your first meeting")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if viewModel.hasTodayMeetings {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Today")
                                        .font(.system(size: 20, weight: .semibold))
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 20)
                                
                                ForEach(viewModel.todayMeetings) { meeting in
                                    MeetingCard(meeting: meeting, viewModel: viewModel)
                                        .padding(.horizontal, 20)
                                }
                            }
                            .padding(.top, 20)
                        }
                        
                        if viewModel.hasUpcomingMeetings {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Upcoming")
                                        .font(.system(size: 20, weight: .semibold))
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 20)
                                
                                ForEach(viewModel.upcomingMeetings) { meeting in
                                    MeetingCard(meeting: meeting, viewModel: viewModel)
                                        .padding(.horizontal, 20)
                                }
                            }
                            .padding(.top, viewModel.hasTodayMeetings ? 20 : 20)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color.white)
        .sheet(isPresented: $showCreateMeeting) {
            CreateMeetingView(viewModel: viewModel)
        }
    }
}



// Meeting Card - WITH THREE-DOT MENU
// Meeting Card - WITH ATTENDEES BUTTON
struct MeetingCard: View {
    let meeting: Meeting
    let viewModel: manViewModel
    @State private var showMeetingOptions = false
    @State private var showEditSheet = false
    @State private var showAttendeesSheet = false
    @State private var editType: EditType = .name
    
    enum EditType {
        case name, date, platform, link, attendees
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Calendar Icon
                VStack(spacing: 2) {
                    Image(systemName: "calendar")
                        .font(.system(size: 24))
                        .foregroundColor(Color("primary"))
                }
                .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(meeting.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("\(meeting.formattedDate) - \(meeting.formattedTime)")
                        .font(.system(size: 14))
                        .foregroundColor(Color("primary"))
                    
                    Text("\(meeting.platform) | \(meeting.projectName)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Three-Dot Menu Button
                Button(action: {
                    showMeetingOptions = true
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color("primary"))
                        .frame(width: 32, height: 32)
                }
                
                // Join Button
                Button(action: {
                    openMeetingLink(meeting.link)
                }) {
                    Text("Join")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color("primary"))
                        .cornerRadius(16)
                }
            }
            
            // Attendees Button
            Button(action: {
                showAttendeesSheet = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("primary"))
                    
                    Text("\(meeting.attendeeCount) attendees")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(16)
        .background(Color("primary2"))
        .cornerRadius(16)
        .confirmationDialog("Meeting Options", isPresented: $showMeetingOptions, titleVisibility: .hidden) {
            Button(action: {
                editType = .name
                showEditSheet = true
            }) {
                Label("Edit Name", systemImage: "pencil")
            }
            
            Button(action: {
                editType = .date
                showEditSheet = true
            }) {
                Label("Edit Date & Time", systemImage: "calendar")
            }
            
            Button(action: {
                editType = .attendees
                showEditSheet = true
            }) {
                Label("Edit Members", systemImage: "person.2")
            }
            
            Button(action: {
                editType = .platform
                showEditSheet = true
            }) {
                Label("Edit Platform", systemImage: "video")
            }
            
            Button(action: {
                editType = .link
                showEditSheet = true
            }) {
                Label("Edit Link", systemImage: "link")
            }
            
            Button("Cancel Meeting", role: .destructive) {
                cancelMeeting()
            }
            
            Button("Close", role: .cancel) {}
        }
        .sheet(isPresented: $showEditSheet) {
            EditMeetingSheet(meeting: meeting, editType: editType, viewModel: viewModel)
        }
        .sheet(isPresented: $showAttendeesSheet) {
            AttendeesListSheet(meeting: meeting)
        }
    }
    
    private func openMeetingLink(_ urlString: String) {
        var cleanURL = urlString.trimmingCharacters(in: .whitespaces)
        if !cleanURL.hasPrefix("http://") && !cleanURL.hasPrefix("https://") {
            cleanURL = "https://" + cleanURL
        }
        if let url = URL(string: cleanURL) {
            UIApplication.shared.open(url)
        }
    }
    
    private func cancelMeeting() {
        viewModel.deleteMeeting(meeting.id.uuidString)
    }
}

// Edit Meeting Sheet
struct EditMeetingSheet: View {
    @Environment(\.dismiss) private var dismiss
    let meeting: Meeting
    let editType: MeetingCard.EditType
    let viewModel: manViewModel
    
    @State private var editedName = ""
    @State private var editedDate = Date()
    @State private var editedPlatform = ""
    @State private var editedLink = ""
    @State private var selectedAttendees: [String] = []
    
    @State private var showDatePicker = false
    @State private var showPlatformPicker = false
    @State private var showAttendeePicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Title
                Text(titleText)
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                
                // Edit Field based on type
                switch editType {
                case .name:
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meeting Name")
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("Meeting name", text: $editedName)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color("primary"), lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, 24)
                    
                case .date:
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date & Time")
                            .font(.system(size: 16, weight: .medium))
                        
                        DatePicker("", selection: $editedDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                            .padding()
                    }
                    .padding(.horizontal, 24)
                    
                case .platform:
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Platform")
                            .font(.system(size: 16, weight: .medium))
                        
                        Button(action: {
                            showPlatformPicker = true
                        }) {
                            HStack {
                                Text(editedPlatform.isEmpty ? "Select platform" : editedPlatform)
                                    .foregroundColor(editedPlatform.isEmpty ? .gray : .black)
                                
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
                    
                case .link:
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meeting Link")
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("URL", text: $editedLink)
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
                    
                case .attendees:
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Members")
                            .font(.system(size: 16, weight: .medium))
                        
                        Button(action: {
                            showAttendeePicker = true
                        }) {
                            HStack {
                                if selectedAttendees.isEmpty {
                                    Text("Select members")
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
                }
                
                Spacer()
                
                // Save Button
                Button(action: {
                    saveMeeting()
                }) {
                    Text("Save Changes")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color("primary"))
                        .cornerRadius(28)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(Color.white)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("primary"))
                }
            }
            .sheet(isPresented: $showPlatformPicker) {
                PlatformPickerView(selectedPlatform: $editedPlatform)
            }
            .sheet(isPresented: $showAttendeePicker) {
                AttendeePickerView(
                    selectedAttendees: $selectedAttendees,
                    communityID: meeting.communityID
                )
            }
            .onAppear {
                setupInitialValues()
            }
        }
    }
    
    private var titleText: String {
        switch editType {
        case .name: return "Edit Meeting Name"
        case .date: return "Edit Date & Time"
        case .platform: return "Edit Platform"
        case .link: return "Edit Meeting Link"
        case .attendees: return "Edit Members"
        }
    }
    
    private func setupInitialValues() {
        editedName = meeting.name
        editedDate = meeting.dateTime
        editedPlatform = meeting.platform
        editedLink = meeting.link
        selectedAttendees = meeting.attendeeIDs
    }
    
    private func saveMeeting() {
        let updatedMeeting = Meeting(
            id: meeting.id,
            name: editedName.isEmpty ? meeting.name : editedName,
            projectID: meeting.projectID,
            projectName: meeting.projectName,
            attendeeIDs: selectedAttendees.isEmpty ? meeting.attendeeIDs : selectedAttendees,
            dateTime: editedDate,
            platform: editedPlatform.isEmpty ? meeting.platform : editedPlatform,
            link: editedLink.isEmpty ? meeting.link : editedLink,
            communityID: meeting.communityID,
            createdAt: meeting.createdAt
        )
        
        viewModel.updateMeeting(updatedMeeting)  // ✅ Call update
        dismiss()
    }
}

// Attendees List Sheet
struct AttendeesListSheet: View {
    @Environment(\.dismiss) private var dismiss
    let meeting: Meeting
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Attendees")
                        .font(.system(size: 28, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(meeting.attendeeCount) people attending")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                Divider()
                
                // Attendees List
                if meeting.attendeeIDs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No attendees yet")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(meeting.attendeeIDs, id: \.self) { attendeeID in
                                AttendeeRow(attendeeID: attendeeID)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .background(Color.white)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("primary"))
                }
            }
        }
    }
}

// Attendee Row
struct AttendeeRow: View {
    let attendeeID: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Picture (placeholder)
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                // TODO: Fetch real name from CloudKit using attendeeID
                Text("User \(attendeeID)")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                
                Text("Member")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("primary2"))
        .cornerRadius(16)
    }
}

#Preview {
    manView()
}
