import SwiftUI

struct ProfileSwitcherSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profileStore: ProfileStore
    @State private var isAddingProfile = false

    var body: some View {
        NavigationStack {
            List {
                Section("Twin profiles") {
                    ForEach(profileStore.profiles) { profile in
                        Button {
                            profileStore.select(profile)
                            dismiss()
                        } label: {
                            HStack(spacing: 14) {
                                avatar(for: profile)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(profile.name).font(.headline)
                                    Text("\(profile.relationship.rawValue) · \(profile.age) years")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if profile.id == profileStore.selectedProfile?.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(EidomeTheme.violet)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    isAddingProfile = true
                } label: {
                    Label("Add a profile", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundStyle(EidomeTheme.cyan)
                }
            }
            .scrollContentBackground(.hidden)
            .background(EidomeTheme.backgroundGradient)
            .navigationTitle("Your twins")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $isAddingProfile) {
                NavigationStack {
                    CreateTwinView(defaultRelationship: .child)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func avatar(for profile: TwinProfile) -> some View {
        Text(profile.name.prefix(1).uppercased())
            .font(.headline)
            .frame(width: 42, height: 42)
            .background(EidomeTheme.violet.opacity(0.24), in: Circle())
            .overlay(Circle().stroke(EidomeTheme.violet.opacity(0.5)))
    }
}
