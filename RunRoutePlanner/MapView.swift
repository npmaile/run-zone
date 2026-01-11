import SwiftUI
import MapKit

// Custom polyline types for different route styles
class PlannedRoutePolyline: MKPolyline {}
class CompletedPathPolyline: MKPolyline {}

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
        mapView.removeOverlays(mapView.overlays)

        if route.count > 1 {
            var routeCoords = route
            let polyline = PlannedRoutePolyline(coordinates: &routeCoords, count: routeCoords.count)
            mapView.addOverlay(polyline)
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

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)

            if overlay is CompletedPathPolyline {
                renderer.strokeColor = UIColor.systemGreen.withAlphaComponent(AppConstants.UI.completedPathAlpha)
                renderer.lineWidth = AppConstants.UI.completedPathWidth
            } else if overlay is PlannedRoutePolyline {
                renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(AppConstants.UI.plannedRouteAlpha)
                renderer.lineWidth = AppConstants.UI.plannedRouteWidth
                renderer.lineDashPattern = AppConstants.UI.plannedRouteDashPattern
            }

            return renderer
        }
    }
}
