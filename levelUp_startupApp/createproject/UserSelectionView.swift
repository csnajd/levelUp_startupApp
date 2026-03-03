import SwiftUI
internal import Combine

struct UserSelectionView: View {
    @Binding var selectedUserIDs: [String]
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: UserSelectionViewModel
    private let communityID: String

    init(communityID: String, selectedUserIDs: Binding<[String]>) {
        self.communityID = communityID
        _selectedUserIDs = selectedUserIDs
        _viewModel = StateObject(wrappedValue: UserSelectionViewModel(communityID: communityID))
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 20, weight: .medium))
                    }

                    Spacer()

                    Text("Select Team Members")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)

                    Spacer()

                    Button(action: { dismiss() }) {
                        Text("Done")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("primary1"))
                    }
                }
                .padding()

                Divider()

                if !selectedUserIDs.isEmpty {
                    HStack {
                        Text("\(selectedUserIDs.count) selected")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }

                if viewModel.isLoading {
                    Spacer()
                    ProgressView().scaleEffect(1.5)
                    Spacer()
                } else if viewModel.members.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.5))

                        Text("No users found")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)

                        Text("Invite team members to get started")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(viewModel.members) { member in
                               TeamMemberRow(
                                    member: member,
                                    isSelected: selectedUserIDs.contains(member.id),
                                    onToggle: { toggleUser(member.id) }
                                )
                                
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadMembers()
        }
    }

    private func toggleUser(_ userID: String) {
        if let index = selectedUserIDs.firstIndex(of: userID) {
            selectedUserIDs.remove(at: index)
        } else {
            selectedUserIDs.append(userID)
        }
    }
}

@MainActor
class UserSelectionViewModel: ObservableObject {
    @Published var members: [TeamMember] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let cloudService = CloudKitService.shared
    private let communityID: String

    init(communityID: String) {
        self.communityID = communityID
    }

    func loadMembers() async {
        isLoading = true
        errorMessage = nil

        do {
            let users = try await cloudService.fetchCommunityMembers(communityID: communityID)
            members = users.map {
                TeamMember(
                    id: $0.appleUserID,
                    email: $0.email.isEmpty ? nil : $0.email,
                    givenName: $0.givenName.isEmpty ? nil : $0.givenName,
                    familyName: $0.familyName.isEmpty ? nil : $0.familyName
                )
            }
            print("✅ Loaded \(members.count) members")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error loading members: \(error)")
        }

        isLoading = false
    }
}
struct TeamMemberRow: View {
    let member: TeamMember
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color("primary1").opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(member.initials)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color("primary1"))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(member.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)

                    if let email = member.email {
                        Text(email)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Color("primary1") : .gray.opacity(0.3))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())

        Divider()
            .padding(.leading, 82)
    }
}
