import SwiftUI

enum DistanceUnit: String, CaseIterable {
    case kilometers = "Kilometers"
    case miles = "Miles"
    
    var abbreviation: String {
        switch self {
        case .kilometers: return "km"
        case .miles: return "mi"
        }
    }
}

class SettingsManager: ObservableObject {
    @Published var distanceUnit: DistanceUnit {
        didSet {
            UserDefaults.standard.set(distanceUnit.rawValue, forKey: "distanceUnit")
        }
    }
    
    init() {
        if let savedUnit = UserDefaults.standard.string(forKey: "distanceUnit"),
           let unit = DistanceUnit(rawValue: savedUnit) {
            self.distanceUnit = unit
        } else {
            self.distanceUnit = .kilometers
        }
    }
    
    // Conversion helpers
    func toKilometers(_ value: Double) -> Double {
        switch distanceUnit {
        case .kilometers:
            return value
        case .miles:
            return value * 1.60934
        }
    }
    
    func fromKilometers(_ km: Double) -> Double {
        switch distanceUnit {
        case .kilometers:
            return km
        case .miles:
            return km * 0.621371
        }
    }
}

struct SettingsView: View {
    @ObservedObject var settings: SettingsManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Distance Units")) {
                    Picker("Preferred Unit", selection: $settings.distanceUnit) {
                        ForEach(DistanceUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settings: SettingsManager())
    }
}
