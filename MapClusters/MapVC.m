#import "MapVC.h"
@import MapKit;
#import "StationsStore.h"
#import "Station.h"
#import "Country.h"

// Clusterers
#import "CCHMapClusterController.h"
#import "CCHMapClusterAnnotation.h"

@interface MapVC() <MKMapViewDelegate>
@property IBOutlet MKMapView * mapView;
@property (nonatomic) CCHMapClusterController *mapClusterController;
@property (nonatomic) StationsStore * store;
@end

@implementation MapVC

- (CCHMapClusterController *)mapClusterController
{
    if(!_mapClusterController && self.viewLoaded) {
        _mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
    }
    return _mapClusterController;
}

- (StationsStore *)store
{
    if(!_store) {
        NSURL * url = [[NSBundle bundleForClass:self.class] URLForResource:@"stations" withExtension:@"csv"];
        _store =  [[StationsStore alloc] initWithCSV:url];
    }
    return _store;
}

- (void)viewDidAppear
{
    [super viewDidAppear];
}

- (void)clearMapContents
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapClusterController removeAnnotations:self.store.stations withCompletionHandler:NULL];
}

- (IBAction)showStationsAnnotations:(id)sender
{
    [self clearMapContents];
    [self.mapView addAnnotations:self.store.stations];
}

- (IBAction)showQuadtreeClusters:(id)sender
{
    [self clearMapContents];
    [self.mapClusterController addAnnotations:self.store.stations withCompletionHandler:NULL];
}

- (IBAction)showCountriesOverlays:(id)sender
{
    [self clearMapContents];
    for (Country* country in self.store.countries) {
        [self.mapView addOverlays:country.polygons];
        [self.mapView addAnnotation:country];
    }
}

// MKMapViewDelegate

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass:CCHMapClusterAnnotation.class]) {
        MKPinAnnotationView * view = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"MapClusters"];
        if(nil==view) {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapClusters"];
        }
        if([(CCHMapClusterAnnotation *)annotation isCluster]) {
            view.pinTintColor = NSColor.greenColor;
        } else {
            view.pinTintColor = NSColor.redColor;
        }
        return view;
    }
 
    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    if([overlay isKindOfClass:MKPolygon.class]) {
        MKPolygonRenderer * renderer = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = NSColor.grayColor;
        renderer.lineWidth = 1;
        return renderer;
    } else {
        return nil;
    }
}

@end
