import SwiftUI
import CloudKit

struct CreateMeetingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: manViewModel
    let communityID: String

    @State private var meetingName = ""
    @State private var selectedProject: Project? = nil
    @State private var selectedAttendees: [String] = []
    @State private var selectedDate = Date()
    @State private var platform = ""
    @State private var link = ""

    @State private var showProjectPicker = false
    @State private var showAttendeePicker = false
    @State private var showDatePicker = false
    @State private var showPlatformPicker = false

    init(viewModel: manViewModel, communityID: String) {
        self.viewModel = viewModel
        self.communityID = communityID
    }

    var isFormValid: Bool {
        !meetingName.isEmpty && selectedProject != nil && !platform.isEmpty && !link.isEmpty
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
                            .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color("primary1"), lineWidth: 2))
                    }
                    .padding(.horizontal, 24)

                    // Project
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Project")
                            .font(.system(size: 16, weight: .medium))
                        Button(action: { showProjectPicker = true }) {
                            HStack {
                                Text(selectedProject?.name ?? "Select project")
                                    .foregroundColor(selectedProject == nil ? .gray : .black)
                                Spacer()
                                Text("select")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16).padding(.vertical, 6)
                                    .background(Color("primary1")).cornerRadius(16)
                            }
                            .padding()
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color("primary1"), lineWidth: 2))
                        }
                    }
                    .padding(.horizontal, 24)

                    // Who can join
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Who can join")
                            .font(.system(size: 16, weight: .medium))
                        Button(action: { showAttendeePicker = true }) {
                            HStack {
                                if selectedAttendees.isEmpty {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.gray)
                                } else {
                                    HStack(spacing: -10) {
                                        ForEach(0..<min(selectedAttendees.count, 3), id: \.self) { _ in
                                            Circle().fill(Color("primary1"))
                                                .frame(width: 28, height: 28)
                                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        }
                                        if selectedAttendees.count > 3 {
                                            Text("+\(selectedAttendees.count - 3)")
                                                .font(.system(size: 12)).foregroundColor(.black).padding(.leading, 8)
                                        }
                                    }
                                }
                                Spacer()
                                Text("select")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16).padding(.vertical, 6)
                                    .background(Color("primary1")).cornerRadius(16)
                            }
                            .padding()
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color("primary1"), lineWidth: 2))
                        }
                    }
                    .padding(.horizontal, 24)

                    // Time and Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time and Date")
                            .font(.system(size: 16, weight: .medium))
                        Button(action: { showDatePicker = true }) {
                            HStack {
                                Text(formatDate(selectedDate))
                                    .foregroundColor(.black)
                                Spacer()
                                Text("select")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16).padding(.vertical, 6)
                                    .background(Color("primary1")).cornerRadius(16)
                            }
                            .padding()
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color("primary1"), lineWidth: 2))
                        }
                    }
                    .padding(.horizontal, 24)

                    // Meeting Platform
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meeting platform")
                            .font(.system(size: 16, weight: .medium))
                        Button(action: { showPlatformPicker = true }) {
                            HStack {
                                Text(platform.isEmpty ? "e.g. Zoom" : platform)
                                    .foregroundColor(platform.isEmpty ? .gray : .black)
                                Spacer()
                                Text("select")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16).padding(.vertical, 6)
                                    .background(Color("primary1")).cornerRadius(16)
                            }
                            .padding()
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color("primary1"), lineWidth: 2))
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
                            .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color("primary1"), lineWidth: 2))
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    }
                    .padding(.horizontal, 24)

                    // Create Button
                    Button(action: { createMeeting() }) {
                        Text("Create New Meeting")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isFormValid ? Color("primary1") : Color.gray)
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
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark").foregroundColor(.black)
                    }
                }
            }
            .sheet(isPresented: $showProjectPicker) {
                ProjectPickerView(communityID: communityID, selectedProject: $selectedProject)
            }
            .sheet(isPresented: $showAttendeePicker) {
                AttendeePickerView(selectedAttendees: $selectedAttendees, communityID: communityID)
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
        guard let project = selectedProject else { return }
        let meeting = Meeting(
            name: meetingName,
            projectID: project.id.uuidString,
            projectName: project.name,
            attendeeIDs: selectedAttendees,
            dateTime: selectedDate,
            platform: platform,
            link: link,
            communityID: communityID,
            createdAt: Date()
        )
        viewModel.addMeeting(meeting)
        dismiss()
    }
}

// MARK: - Project Picker
struct ProjectPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedProject: Project?
    let communityID: String

    @State private var projects: [Project] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let cloudKitService = CloudKitService.shared

    init(communityID: String, selectedProject: Binding<Project?>) {
        self.communityID = communityID
        _selectedProject = selectedProject
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading projects...")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48)).foregroundColor(.orange)
                        Text("Error loading projects")
                            .font(.headline)
                        Text(error)
                            .font(.subheadline).foregroundColor(.gray)
                            .multilineTextAlignment(.center).padding(.horizontal)
                        Button("Retry") { Task { await loadProjects() } }
                            .buttonStyle(.borderedProminent).tint(Color("primary1"))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        // Option: Not related to any project
                        Button(action: {
                            selectedProject = Project(
                                name: "Not related to any project",
                                memberIDs: [],
                                isBlocked: false,
                                blockReason: nil,
                                createdAt: Date(),
                                communityID: communityID
                            )
                            dismiss()
                        }) {
                            HStack {
                                Text("Not related to any project")
                                    .foregroundColor(.gray)
                                Spacer()
                                if selectedProject?.name == "Not related to any project" {
                                    Image(systemName: "checkmark").foregroundColor(Color("primary1"))
                                }
                            }
                        }

                        ForEach(projects) { project in
                            Button(action: {
                                selectedProject = project
                                dismiss()
                            }) {
                                HStack {
                                    Text(project.name).foregroundColor(.black)
                                    Spacer()
                                    if selectedProject?.id == project.id {
                                        Image(systemName: "checkmark").foregroundColor(Color("primary1"))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(Color("primary1"))
                }
            }
            .task { await loadProjects() }
        }
    }

    private func loadProjects() async {
        isLoading = true
        errorMessage = nil
        do {
            projects = try await cloudKitService.fetchCommunityProjects(communityID: communityID)
            print("✅ Loaded \(projects.count) projects")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error loading projects: \(error)")
        }
        isLoading = false
    }
}

// MARK: - Attendee Picker
struct AttendeePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAttendees: [String]
    var communityID: String
    private let cloudKitService = CloudKitService.shared

    @State private var communityMembers: [User] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading members...").foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48)).foregroundColor(.orange)
                        Text("Error Loading Members").font(.headline)
                        Text(error).font(.subheadline).foregroundColor(.gray)
                            .multilineTextAlignment(.center).padding(.horizontal)
                        Button("Retry") { Task { await loadCommunityMembers() } }
                            .buttonStyle(.borderedProminent).tint(Color("primary1"))
                    }
                    .padding()
                } else if communityMembers.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 48)).foregroundColor(.gray)
                        Text("No community members found").font(.headline).foregroundColor(.gray)
                        Text("Invite people to join your community").font(.subheadline).foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(communityMembers) { member in
                            Button(action: { toggleMember(member.id) }) {
                                HStack(spacing: 12) {
                                    if let image = member.profileImage {
                                        Image(uiImage: image)
                                            .resizable().scaledToFill()
                                            .frame(width: 40, height: 40).clipShape(Circle())
                                    } else {
                                        Circle().fill(Color("primary1").opacity(0.2))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Text(member.givenName.prefix(1).uppercased())
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(Color("primary1"))
                                            )
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(member.fullName)
                                            .font(.system(size: 16, weight: .medium)).foregroundColor(.primary)
                                        if !member.email.isEmpty && member.showEmail {
                                            Text(member.email).font(.system(size: 14)).foregroundColor(.gray)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: selectedAttendees.contains(member.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedAttendees.contains(member.id) ? Color("primary1") : .gray.opacity(0.3))
                                        .font(.system(size: 24))
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        if !selectedAttendees.isEmpty {
                            Section {
                                HStack {
                                    Text("\(selectedAttendees.count) member\(selectedAttendees.count == 1 ? "" : "s") selected")
                                        .font(.subheadline).foregroundColor(.gray)
                                    Spacer()
                                    Button("Clear All") { selectedAttendees.removeAll() }
                                        .font(.subheadline).foregroundColor(Color("primary1"))
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
                    if !communityMembers.isEmpty {
                        Button("Select All") {
                            selectedAttendees = communityMembers.map { $0.id }
                        }
                        .font(.subheadline).foregroundColor(Color("primary1"))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color("primary1")).fontWeight(.semibold)
                }
            }
            .task { await loadCommunityMembers() }
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
            print("✅ Loaded \(communityMembers.count) members")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error loading members: \(error)")
        }
        isLoading = false
    }
}

// MARK: - Date Picker
struct DatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker("Select Date and Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical).padding()
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

// MARK: - Platform Picker
struct PlatformPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPlatform: String
    let platforms = ["Zoom", "Webex", "Google Meet", "Microsoft Teams"]

    var body: some View {
        NavigationStack {
            List(platforms, id: \.self) { platform in
                Button(action: { selectedPlatform = platform; dismiss() }) {
                    HStack {
                        Text(platform)
                        Spacer()
                        if selectedPlatform == platform {
                            Image(systemName: "checkmark").foregroundColor(Color("primary1"))
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
    CreateMeetingView(
        viewModel: manViewModel(communityID: "test-community"),
        communityID: "test-community"
    )
}
