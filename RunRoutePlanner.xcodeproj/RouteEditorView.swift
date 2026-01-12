import SwiftUI
import MapKit

/// Manual Route Editor View
/// Allows users to drag waypoints and customize their route
struct RouteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var routePlanner: RoutePlanner
    @State private var editableWaypoints: [EditableWaypoint] = []
    @State private var selectedWaypointIndex: Int?
    @State private var showAddWaypointMode = false
    @State private var hasUnsavedChanges = false
    @State private var showDiscardAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map with editable waypoints
                RouteEditorMapView(
                    waypoints: $editableWaypoints,
                    route: routePlanner.currentRoute,
                    selectedIndex: $selectedWaypointIndex,
                    addMode: $showAddWaypointMode,
                    onWaypointMoved: {
                        hasUnsavedChanges = true
                    }
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Top instruction banner
                    topInstructionBanner
                    
                    Spacer()
                    
                    // Bottom controls
                    bottomControls
                }
            }
            .navigationTitle("Edit Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if hasUnsavedChanges {
                            showDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(.appDanger)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundColor(.appSuccess)
                    .fontWeight(.semibold)
                    .disabled(!hasUnsavedChanges)
                }
            }
            .alert("Discard Changes?", isPresented: $showDiscardAlert) {
                Button("Discard", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("You have unsaved route changes.")
            }
        }
        .onAppear {
            loadWaypoints()
        }
    }
    
    // MARK: - Top Banner
    
    private var topInstructionBanner: some View {
        VStack(spacing: 8) {
            if showAddWaypointMode {
                HStack(spacing: 8) {
                    Image(systemName: "hand.tap.fill")
                        .foregroundColor(.appSuccess)
                    Text("Tap on map to add waypoint")
                        .font(.subheadline)
                        .foregroundColor(.appTextPrimary)
                }
                .padding()
                .background(Color.appSuccess.opacity(0.2))
                .cornerRadius(12)
            } else if let index = selectedWaypointIndex {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                        .foregroundColor(.appInfo)
                    Text("Drag waypoint \(index + 1) to new position")
                        .font(.subheadline)
                        .foregroundColor(.appTextPrimary)
                }
                .padding()
                .background(Color.appInfo.opacity(0.2))
                .cornerRadius(12)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "hand.point.up.left.fill")
                        .foregroundColor(.appTextSecondary)
                    Text("Tap waypoint to select or drag to move")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }
                .padding()
                .background(Color.appCardBackground)
                .cornerRadius(12)
            }
        }
        .padding()
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControls: some View {
        VStack(spacing: 12) {
            // Waypoint list
            if !editableWaypoints.isEmpty {
                waypointListSection
            }
            
            // Action buttons
            HStack(spacing: 12) {
                // Add waypoint button
                Button(action: {
                    showAddWaypointMode.toggle()
                    selectedWaypointIndex = nil
                    hapticFeedback(.light)
                }) {
                    HStack {
                        Image(systemName: showAddWaypointMode ? "xmark" : "plus.circle.fill")
                        Text(showAddWaypointMode ? "Cancel" : "Add Point")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(showAddWaypointMode ? Color.appDanger : Color.appSuccess)
                    .cornerRadius(12)
                }
                
                // Delete selected waypoint
                if let index = selectedWaypointIndex, editableWaypoints.count > 3 {
                    Button(action: {
                        deleteWaypoint(at: index)
                        hapticFeedback(.medium)
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Delete")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appDanger)
                        .cornerRadius(12)
                    }
                }
                
                // Reset to original
                Button(action: {
                    resetToOriginal()
                    hapticFeedback(.medium)
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.appTextPrimary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appCardBackground)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.appElevatedBackground)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: Color.appShadow, radius: 10, x: 0, y: -4)
    }
    
    // MARK: - Waypoint List
    
    private var waypointListSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(editableWaypoints.enumerated()), id: \.element.id) { index, waypoint in
                    waypointChip(index: index, waypoint: waypoint)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 60)
    }
    
    private func waypointChip(index: Int, waypoint: EditableWaypoint) -> some View {
        Button(action: {
            if selectedWaypointIndex == index {
                selectedWaypointIndex = nil
            } else {
                selectedWaypointIndex = index
                showAddWaypointMode = false
            }
            hapticFeedback(.light)
        }) {
            VStack(spacing: 4) {
                Image(systemName: index == 0 ? "flag.fill" : "mappin.circle.fill")
                    .font(.title3)
                    .foregroundColor(selectedWaypointIndex == index ? .white : .appInfo)
                
                Text(index == 0 ? "Start" : "\(index)")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(selectedWaypointIndex == index ? .white : .appTextPrimary)
            }
            .frame(width: 50, height: 50)
            .background(
                selectedWaypointIndex == index ? Color.appInfo : Color.appCardBackground
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selectedWaypointIndex == index ? Color.appInfo : Color.clear, lineWidth: 2)
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadWaypoints() {
        editableWaypoints = routePlanner.currentWaypoints.enumerated().map { index, coordinate in
            EditableWaypoint(
                id: UUID(),
                coordinate: coordinate,
                originalIndex: index
            )
        }
    }
    
    private func saveChanges() {
        // Update route planner with new waypoints
        let newWaypoints = editableWaypoints.map { $0.coordinate }
        routePlanner.updateWaypoints(newWaypoints)
        
        hasUnsavedChanges = false
        hapticNotification(.success)
        dismiss()
    }
    
    private func deleteWaypoint(at index: Int) {
        guard editableWaypoints.count > 3 else { return } // Keep minimum 3 waypoints
        editableWaypoints.remove(at: index)
        selectedWaypointIndex = nil
        hasUnsavedChanges = true
    }
    
    private func resetToOriginal() {
        loadWaypoints()
        selectedWaypointIndex = nil
        showAddWaypointMode = false
        hasUnsavedChanges = false
    }
}

// MARK: - Editable Waypoint Model

struct EditableWaypoint: Identifiable, Equatable {
    let id: UUID
    var coordinate: CLLocationCoordinate2D
    let originalIndex: Int
    
    static func == (lhs: EditableWaypoint, rhs: EditableWaypoint) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Route Editor Map View

struct RouteEditorMapView: UIViewRepresentable {
    @Binding var waypoints: [EditableWaypoint]
    let route: [CLLocationCoordinate2D]
    @Binding var selectedIndex: Int?
    @Binding var addMode: Bool
    let onWaypointMoved: () -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        // Add tap gesture for adding waypoints
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.parent = self
        
        // Remove existing annotations and overlays
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        mapView.removeOverlays(mapView.overlays)
        
        // Add waypoint annotations
        for (index, waypoint) in waypoints.enumerated() {
            let annotation = WaypointAnnotation(
                coordinate: waypoint.coordinate,
                title: index == 0 ? "Start" : "Point \(index)",
                index: index
            )
            mapView.addAnnotation(annotation)
        }
        
        // Add route overlay
        if route.count > 1 {
            var routeCoords = route
            let polyline = MKPolyline(coordinates: &routeCoords, count: routeCoords.count)
            mapView.addOverlay(polyline)
        }
        
        // Zoom to show all waypoints
        if !waypoints.isEmpty {
            let coordinates = waypoints.map { $0.coordinate }
            let region = coordinateRegion(for: coordinates)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RouteEditorMapView
        
        init(_ parent: RouteEditorMapView) {
            self.parent = parent
        }
        
        // MARK: - Annotation View
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let waypointAnnotation = annotation as? WaypointAnnotation else {
                return nil
            }
            
            let identifier = "WaypointAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.isDraggable = true
                annotationView?.canShowCallout = false
            } else {
                annotationView?.annotation = annotation
            }
            
            // Style based on selection
            let isSelected = parent.selectedIndex == waypointAnnotation.index
            let isStart = waypointAnnotation.index == 0
            
            if isStart {
                annotationView?.markerTintColor = .systemGreen
                annotationView?.glyphImage = UIImage(systemName: "flag.fill")
            } else if isSelected {
                annotationView?.markerTintColor = .systemBlue
                annotationView?.glyphText = "\(waypointAnnotation.index)"
            } else {
                annotationView?.markerTintColor = .systemBlue.withAlphaComponent(0.6)
                annotationView?.glyphText = "\(waypointAnnotation.index)"
            }
            
            return annotationView
        }
        
        // MARK: - Annotation Selection
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let waypointAnnotation = view.annotation as? WaypointAnnotation else { return }
            parent.selectedIndex = waypointAnnotation.index
            parent.addMode = false
        }
        
        // MARK: - Annotation Drag
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
            guard let waypointAnnotation = view.annotation as? WaypointAnnotation else { return }
            
            if newState == .ending {
                let newCoordinate = view.annotation!.coordinate
                let index = waypointAnnotation.index
                
                if index < parent.waypoints.count {
                    parent.waypoints[index].coordinate = newCoordinate
                    parent.onWaypointMoved()
                }
            }
        }
        
        // MARK: - Map Tap (Add Waypoint)
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard parent.addMode else { return }
            
            let mapView = gesture.view as! MKMapView
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            // Add new waypoint before the last one (which should return to start)
            let insertIndex = max(1, parent.waypoints.count - 1)
            let newWaypoint = EditableWaypoint(
                id: UUID(),
                coordinate: coordinate,
                originalIndex: insertIndex
            )
            parent.waypoints.insert(newWaypoint, at: insertIndex)
            parent.onWaypointMoved()
            parent.addMode = false
            
            hapticFeedback(.medium)
        }
        
        // MARK: - Overlay Rendering
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.6)
            renderer.lineWidth = 4
            renderer.lineDashPattern = [10, 5]
            return renderer
        }
    }
    
    // Helper to calculate region
    private func coordinateRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var minLat = coordinates[0].latitude
        var maxLat = coordinates[0].latitude
        var minLon = coordinates[0].longitude
        var maxLon = coordinates[0].longitude
        
        for coord in coordinates {
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLon = min(minLon, coord.longitude)
            maxLon = max(maxLon, coord.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
}

// MARK: - Waypoint Annotation

class WaypointAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    let index: Int
    
    init(coordinate: CLLocationCoordinate2D, title: String?, index: Int) {
        self.coordinate = coordinate
        self.title = title
        self.index = index
        super.init()
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Haptic Helpers

private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}

private func hapticNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(type)
}
