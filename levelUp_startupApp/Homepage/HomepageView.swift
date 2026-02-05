//
//  HomepageView.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 02/02/2026.
//

import SwiftUI

struct HomepageView: View {

    @StateObject private var vm = HomepageViewModel()

    @State private var showAdd = false
    @State private var projectName = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {

                Button {
                    showAdd = true
                } label: {
                    Text("+ Create Project")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                if vm.isLoading {
                    ProgressView()
                }

                if let msg = vm.errorMessage {
                    Text(msg)
                        .foregroundStyle(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                List {
                    ForEach(vm.projects) { p in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(p.title)
                                .font(.headline)

                            Text(p.createdAt, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: vm.delete)
                }
                .listStyle(.plain)
            }
            .padding()
            .navigationTitle("company name")
            .onAppear { vm.load() }
            .alert("New Project", isPresented: $showAdd) {
                TextField("Project name", text: $projectName)

                Button("Add") {
                    vm.addProject(title: projectName)
                    projectName = ""
                }

                Button("Cancel", role: .cancel) {
                    projectName = ""
                }
            } message: {
                Text("Enter a project name")
            }
        }
    }
}
#Preview {
    HomepageView()
}
