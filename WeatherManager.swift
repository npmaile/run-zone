import Foundation
import WeatherKit
import CoreLocation

@MainActor
class WeatherManager: ObservableObject {
    private let weatherService = WeatherService.shared
    
    @Published var currentWeather: Weather?
    @Published var temperature: Double?
    @Published var condition: String?
    @Published var humidity: Double?
    @Published var windSpeed: Double?
    @Published var isLoading = false
    @Published var error: String?
    
    func fetchWeather(for location: CLLocationCoordinate2D) async {
        isLoading = true
        error = nil
        
        do {
            let weather = try await weatherService.weather(for: .init(latitude: location.latitude, longitude: location.longitude))
            
            currentWeather = weather
            temperature = weather.currentWeather.temperature.value
            condition = weather.currentWeather.condition.description
            humidity = weather.currentWeather.humidity
            windSpeed = weather.currentWeather.wind.speed.value
            
        } catch {
            self.error = "Unable to fetch weather: \(error.localizedDescription)"
            print("Weather fetch error: \(error)")
        }
        
        isLoading = false
    }
    
    func getRunningConditionRating() -> RunningCondition {
        guard let temp = temperature else { return .unknown }
        
        // Optimal running temperature is around 10-15°C (50-60°F)
        switch temp {
        case ..<0:
            return .veryHard // Freezing
        case 0..<5:
            return .hard // Very cold
        case 5..<10:
            return .moderate // Cold
        case 10..<15:
            return .ideal // Perfect!
        case 15..<20:
            return .good // Warm
        case 20..<25:
            return .moderate // Getting hot
        case 25..<30:
            return .hard // Hot
        default:
            return .veryHard // Very hot
        }
    }
    
    func getRunningAdvice() -> String {
        guard let temp = temperature else { return "Weather data unavailable" }
        
        let condition = getRunningConditionRating()
        
        switch condition {
        case .ideal:
            return "Perfect weather for running! 🌤️"
        case .good:
            return "Great conditions for a run! ☀️"
        case .moderate:
            if temp < 15 {
                return "A bit chilly. Wear layers! 🧥"
            } else {
                return "Getting warm. Stay hydrated! 💧"
            }
        case .hard:
            if temp < 15 {
                return "Cold! Dress warmly and warm up properly. ❄️"
            } else {
                return "Hot! Take it easy and drink plenty of water. 🌡️"
            }
        case .veryHard:
            if temp < 15 {
                return "Very cold! Be careful and keep extremities warm. 🥶"
            } else {
                return "Very hot! Consider running early morning or evening. 🔥"
            }
        case .unknown:
            return "Weather data unavailable"
        }
    }
    
    func getConditionIcon() -> String {
        guard let condition = currentWeather?.currentWeather.condition else {
            return "questionmark.circle"
        }
        
        switch condition {
        case .clear:
            return "sun.max.fill"
        case .cloudy:
            return "cloud.fill"
        case .mostlyClear:
            return "cloud.sun.fill"
        case .mostlyCloudy:
            return "cloud.sun.fill"
        case .partlyCloudy:
            return "cloud.sun.fill"
        case .rain:
            return "cloud.rain.fill"
        case .heavyRain:
            return "cloud.heavyrain.fill"
        case .snow:
            return "snow"
        case .sleet:
            return "cloud.sleet.fill"
        case .hail:
            return "cloud.hail.fill"
        case .thunderstorms:
            return "cloud.bolt.rain.fill"
        case .fog:
            return "cloud.fog.fill"
        case .windy:
            return "wind"
        default:
            return "cloud.fill"
        }
    }
}

enum RunningCondition {
    case ideal
    case good
    case moderate
    case hard
    case veryHard
    case unknown
    
    var color: String {
        switch self {
        case .ideal: return "green"
        case .good: return "blue"
        case .moderate: return "yellow"
        case .hard: return "orange"
        case .veryHard: return "red"
        case .unknown: return "gray"
        }
    }
}
