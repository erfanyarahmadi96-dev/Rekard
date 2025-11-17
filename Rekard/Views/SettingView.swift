//
//  SettingView.swift
//  Rekard
//
//  Created by Erfan Yarahmadi on 14/11/25.
//

import SwiftUI

struct SettingView: View {
    @State private var notificationsEnabled: Bool = true

    private var appVersion: String {
        let version =
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? ""
        let build =
            Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return [version, build].filter { !$0.isEmpty }.joined(separator: " (")
            + (build.isEmpty ? "" : ")")
    }

    var body: some View {
        ZStack {
            LinearGradient.appBackground
                .ignoresSafeArea()

            List {

                Section(

                    header: Text("Notifications"),
                    footer: Text(
                        "You can fine-tune notification settings in iOS Settings > Rekard."
                    )
                ) {
                    Toggle(isOn: $notificationsEnabled) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundStyle(.red)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Enable notifications")
                                Text("Allow reminders and progress updates")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section(header: Text("About")) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Version")
                            Text(appVersion.isEmpty ? "—" : appVersion)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    NavigationLink {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Privacy Policy")
                                    .font(.title3).bold()
                                Text(
                                    "Your privacy matters. We only store what we need to deliver your study experience."
                                )
                                Text("More details coming soon.")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                        }
                        .background(Color.clear)
                    } label: {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }

                    NavigationLink {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Terms of Use")
                                    .font(.title3).bold()
                                Text(
                                    "Please review the terms governing your use of Rekard."
                                )
                                Text("More details coming soon.")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                        }
                        .background(Color.clear)
                    } label: {
                        Label("Terms of Use", systemImage: "doc.text")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.headline)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingView()
    }
}
