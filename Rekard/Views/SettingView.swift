//
//  SettingView.swift
//  Rekard
//
//  Created by Erfan Yarahmadi on 14/11/25.
//

import SwiftUI

struct SettingView: View {
    @State private var notificationsEnabled: Bool = true
    @State private var hapticsEnabled: Bool = true
    @State private var darkMode: Bool = false
    @State private var studyReminders: Bool = false
    @State private var dailyGoal: Int = 20

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
                    header: Text("Study"),
                    footer: Text(
                        "Reminders help you stay consistent with your Leitner boxes."
                    )
                ) {
                    Stepper(
                        value: $dailyGoal,
                        in: 5...200,
                        step: 5,
                        label: {
                            HStack {
                                Image(systemName: "target")
                                    .foregroundStyle(.pink)
                                Text("Daily goal")
                                Spacer()
                                Text("\(dailyGoal)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    )

                    Toggle(isOn: $studyReminders) {
                        HStack {
                            Image(systemName: "bell.badge")
                                .foregroundStyle(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Study reminders")
                                Text("Get a nudge to review cards")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section(header: Text("Appearance")) {
                    Toggle(isOn: $darkMode) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundStyle(.purple)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Dark Mode")
                                Text("Use a darker theme for low light")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Toggle(isOn: $hapticsEnabled) {
                        HStack {
                            Image(systemName: "waveform")
                                .foregroundStyle(.teal)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Haptics")
                                Text("Subtle feedback during study")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

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
