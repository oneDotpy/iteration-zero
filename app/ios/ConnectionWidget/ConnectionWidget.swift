import WidgetKit
import SwiftUI

// MARK: - Shared helpers

private let appGroup = "group.connection.app"

private func defaults() -> UserDefaults {
    UserDefaults(suiteName: appGroup) ?? .standard
}

// MARK: - Caregiver Widget

struct CaregiverEntry: TimelineEntry {
    let date: Date
    let patientName: String
    let feelUnsure: Int
    let hearVoice: Int
    let breather: Int
    let appOpens: Int
}

struct CaregiverProvider: TimelineProvider {
    func placeholder(in context: Context) -> CaregiverEntry {
        CaregiverEntry(date: .now, patientName: "Margaret", feelUnsure: 2, hearVoice: 3, breather: 1, appOpens: 4)
    }

    func getSnapshot(in context: Context, completion: @escaping (CaregiverEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CaregiverEntry>) -> Void) {
        let e = entry()
        // Refresh every 15 minutes
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: e.date)!
        completion(Timeline(entries: [e], policy: .after(next)))
    }

    private func entry() -> CaregiverEntry {
        let d = defaults()
        return CaregiverEntry(
            date: .now,
            patientName: d.string(forKey: "cg_patient_name") ?? "Your care recipient",
            feelUnsure: d.integer(forKey: "cg_feel_unsure"),
            hearVoice: d.integer(forKey: "cg_hear_voice"),
            breather: d.integer(forKey: "cg_breather"),
            appOpens: d.integer(forKey: "cg_app_opens")
        )
    }
}

struct CaregiverWidgetView: View {
    let entry: CaregiverEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            Color(red: 0.91, green: 0.97, blue: 0.96) // teal light
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "shield.fill")
                        .foregroundColor(Color(red: 0.36, green: 0.66, blue: 0.62))
                        .font(.caption)
                    Text("Today's Activity")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.36, green: 0.66, blue: 0.62))
                }
                Text(entry.patientName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if family != .systemSmall {
                    Spacer(minLength: 2)
                }

                HStack(spacing: 10) {
                    StatPill(icon: "questionmark.circle", count: entry.feelUnsure, color: Color(red: 0.85, green: 0.45, blue: 0.50))
                    StatPill(icon: "waveform", count: entry.hearVoice, color: Color(red: 0.55, green: 0.72, blue: 0.57))
                    StatPill(icon: "wind", count: entry.breather, color: Color(red: 0.47, green: 0.60, blue: 0.80))
                }

                if family == .systemMedium {
                    HStack {
                        Image(systemName: "phone.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(entry.appOpens) opens today")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct StatPill: View {
    let icon: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .cornerRadius(10)
    }
}

struct CaregiverWidget: Widget {
    let kind = "CaregiverWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CaregiverProvider()) { entry in
            CaregiverWidgetView(entry: entry)
        }
        .configurationDisplayName("Care Recipient Activity")
        .description("See today's activity for your care recipient at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Patient Widget

struct PatientEntry: TimelineEntry {
    let date: Date
    let headline: String
    let subtext: String
    let caregiverName: String
    let hasMessage: Bool
}

struct PatientProvider: TimelineProvider {
    func placeholder(in context: Context) -> PatientEntry {
        PatientEntry(date: .now, headline: "You are safe.", subtext: "Take a slow breath.", caregiverName: "Alex", hasMessage: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (PatientEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PatientEntry>) -> Void) {
        let e = entry()
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: e.date)!
        completion(Timeline(entries: [e], policy: .after(next)))
    }

    private func entry() -> PatientEntry {
        let d = defaults()
        return PatientEntry(
            date: .now,
            headline: d.string(forKey: "pt_headline") ?? "You are safe.",
            subtext: d.string(forKey: "pt_subtext") ?? "Take a slow breath.",
            caregiverName: d.string(forKey: "pt_caregiver_name") ?? "Your caregiver",
            hasMessage: d.bool(forKey: "pt_has_message")
        )
    }
}

struct PatientWidgetView: View {
    let entry: PatientEntry

    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.93, blue: 0.93) // rose light
            VStack(alignment: .center, spacing: 8) {
                Image(systemName: "heart.fill")
                    .foregroundColor(Color(red: 0.85, green: 0.45, blue: 0.50))
                    .font(.title3)

                Text(entry.headline)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)

                if !entry.subtext.isEmpty {
                    Text(entry.subtext)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Text("From \(entry.caregiverName)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.85, green: 0.45, blue: 0.50))
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct PatientWidget: Widget {
    let kind = "PatientWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PatientProvider()) { entry in
            PatientWidgetView(entry: entry)
        }
        .configurationDisplayName("Reassurance")
        .description("A comforting message from your caregiver, always visible.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Bundle

@main
struct ConnectionWidgetBundle: WidgetBundle {
    var body: some Widget {
        CaregiverWidget()
        PatientWidget()
    }
}
