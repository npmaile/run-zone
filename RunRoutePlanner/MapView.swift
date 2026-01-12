import SwiftUI
import MapKit

// Custom polyline types for different route styles
class PlannedRoutePolyline: MKPolyline {}
class CompletedPathPolyline: MKPolyline {}

struct MapView: UIViewRepresentable {
    var userLocation: CLLocationCoordinate2D?
    var route: [CLLocationCoordinate2D]
    var completedPath: [CLLocationCoordinate2D]
    var showDirectionalArrows: Bool = false

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update coordinator's arrow visibility
        context.coordinator.showDirectionalArrows = showDirectionalArrows
        
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })

        if route.count > 1 {
            var routeCoords = route
            let polyline = PlannedRoutePolyline(coordinates: &routeCoords, count: routeCoords.count)
            mapView.addOverlay(polyline)
            
            // Add directional arrows if enabled
            if showDirectionalArrows {
                let arrows = context.coordinator.createDirectionalArrows(for: route)
                mapView.addAnnotations(arrows)
            }
        }

        if completedPath.count > 1 {
            var pathCoords = completedPath
            let polyline = CompletedPathPolyline(coordinates: &pathCoords, count: pathCoords.count)
            mapView.addOverlay(polyline)
        }

        if let location = userLocation {
            let region = MKCoordinateRegion(
                center: location,
                latitudinalMeters: AppConstants.Location.mapZoomMeters,
                longitudinalMeters: AppConstants.Location.mapZoomMeters
            )
            mapView.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var showDirectionalArrows: Bool = false

        init(_ parent: MapView) {
            self.parent = parent
        }
        
        /// Creates directional arrow annotations along the route
        func createDirectionalArrows(for route: [CLLocationCoordinate2D]) -> [DirectionalArrowAnnotation] {
            var arrows: [DirectionalArrowAnnotation] = []
            
            // Place arrows at regular intervals
            let totalPoints = route.count
            let arrowInterval = max(totalPoints / 8, 10) // About 8 arrows, but at least every 10 points
            
            for i in stride(from: arrowInterval, to: totalPoints - 1, by: arrowInterval) {
                let start = route[i]
                let end = route[min(i + 5, totalPoints - 1)] // Look ahead a bit for direction
                
                let bearing = calculateBearing(from: start, to: end)
                let arrow = DirectionalArrowAnnotation(coordinate: start, bearing: bearing)
                arrows.append(arrow)
            }
            
            return arrows
        }
        
        /// Calculates bearing between two coordinates in degrees
        private func calculateBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
            let lat1 = from.latitude * .pi / 180
            let lon1 = from.longitude * .pi / 180
            let lat2 = to.latitude * .pi / 180
            let lon2 = to.longitude * .pi / 180
            
            let dLon = lon2 - lon1
            let y = sin(dLon) * cos(lat2)
            let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
            let bearing = atan2(y, x) * 180 / .pi
            
            return (bearing + 360).truncatingRemainder(dividingBy: 360)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)

            if overlay is CompletedPathPolyline {
                // Use brighter green for dark mode visibility
                let isDarkMode = mapView.traitCollection.userInterfaceStyle == .dark
                let baseColor = isDarkMode 
                    ? UIColor(red: 0.3, green: 0.9, blue: 0.4, alpha: 1.0)
                    : UIColor.systemGreen
                renderer.strokeColor = baseColor.withAlphaComponent(AppConstants.UI.completedPathAlpha)
                renderer.lineWidth = AppConstants.UI.completedPathWidth
            } else if overlay is PlannedRoutePolyline {
                // Use brighter blue for dark mode visibility
                let isDarkMode = mapView.traitCollection.userInterfaceStyle == .dark
                let baseColor = isDarkMode
                    ? UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0)
                    : UIColor.systemBlue
                renderer.strokeColor = baseColor.withAlphaComponent(AppConstants.UI.plannedRouteAlpha)
                renderer.lineWidth = AppConstants.UI.plannedRouteWidth
                renderer.lineDashPattern = AppConstants.UI.plannedRouteDashPattern
            }

            return renderer
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let arrow = annotation as? DirectionalArrowAnnotation else {
                return nil
            }
            
            let identifier = "DirectionalArrow"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: arrow, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
            } else {
                annotationView?.annotation = arrow
            }
            
            // Create arrow image
            let isDarkMode = mapView.traitCollection.userInterfaceStyle == .dark
            let arrowColor = isDarkMode
                ? UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0)
                : UIColor.systemBlue
            
            annotationView?.image = createArrowImage(color: arrowColor)
            annotationView?.transform = CGAffineTransform(rotationAngle: arrow.bearing * .pi / 180)
            
            return annotationView
        }
        
        /// Creates an arrow image for the annotation
        private func createArrowImage(color: UIColor) -> UIImage {
            let size = CGSize(width: 20, height: 20)
            let renderer = UIGraphicsImageRenderer(size: size)
            
            return renderer.image { context in
                let path = UIBezierPath()
                
                // Draw a simple arrow pointing up (will be rotated)
                path.move(to: CGPoint(x: 10, y: 2))
                path.addLine(to: CGPoint(x: 16, y: 10))
                path.addLine(to: CGPoint(x: 12, y: 10))
                path.addLine(to: CGPoint(x: 12, y: 18))
                path.addLine(to: CGPoint(x: 8, y: 18))
                path.addLine(to: CGPoint(x: 8, y: 10))
                path.addLine(to: CGPoint(x: 4, y: 10))
                path.close()
                
                color.setFill()
                path.fill()
            }
        }
    }
}
// MARK: - Directional Arrow Annotation

class DirectionalArrowAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let bearing: Double
    
    init(coordinate: CLLocationCoordinate2D, bearing: Double) {
        self.coordinate = coordinate
        self.bearing = bearing
        super.init()
    }
}

