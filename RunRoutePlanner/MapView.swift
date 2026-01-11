import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    var userLocation: CLLocationCoordinate2D?
    var route: [CLLocationCoordinate2D]
    var completedPath: [CLLocationCoordinate2D]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Remove existing overlays
        mapView.removeOverlays(mapView.overlays)

        // Add planned route overlay (blue line)
        if route.count > 1 {
            let polyline = MKPolyline(coordinates: route, count: route.count)
            mapView.addOverlay(polyline)
        }

        // Add completed path overlay (green line)
        if completedPath.count > 1 {
            let completedPolyline = MKPolyline(coordinates: completedPath, count: completedPath.count)
            mapView.addOverlay(completedPolyline)
        }

        // Center map on user location if available
        if let location = userLocation {
            let region = MKCoordinateRegion(
                center: location,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            mapView.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)

                // Check if this is the completed path or planned route
                // We'll use different colors
                if parent.completedPath.count > 1 &&
                   polyline.pointCount == parent.completedPath.count {
                    // Completed path - green
                    renderer.strokeColor = UIColor.systemGreen.withAlphaComponent(0.8)
                    renderer.lineWidth = 6
                } else {
                    // Planned route - blue
                    renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.6)
                    renderer.lineWidth = 4
                    renderer.lineDashPattern = [10, 5] // Dashed line
                }

                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
