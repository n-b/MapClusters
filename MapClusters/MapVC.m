#import "MapVC.h"
@import MapKit;
#import "StationsStore.h"
#import "Station.h"
#import "Country.h"
#import "StationsOverlayRenderer.h"

// Clusterers
#import "CCHMapClusterController.h"
#import "CCHMapClusterAnnotation.h"
#import "CCHMapClusterControllerDelegate.h"

#import "ADClusterMapView.h"

@interface MapVC() <MKMapViewDelegate, CCHMapClusterControllerDelegate, ADClusterMapViewDelegate>
@property IBOutlet MKMapView * mapView;
@property IBOutlet ADClusterMapView * adClusterMapView;
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
    [self showCountriesOverlays:nil];
}

- (void)clearMapContents
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    self.mapView.hidden = YES;
    self.adClusterMapView.hidden = YES;
    [_mapClusterController removeAnnotations:self.store.stations withCompletionHandler:NULL];
}

- (IBAction)showStationsAnnotations:(id)sender
{
    [self clearMapContents];
    self.mapView.hidden = NO;
    [self.mapView addAnnotations:self.store.stations];
}

- (IBAction)showQuadtreeClusters:(id)sender
{
    [self clearMapContents];
    self.mapView.hidden = NO;
    [self.mapClusterController addAnnotations:self.store.stations withCompletionHandler:NULL];
}

- (IBAction)showCountriesOverlays:(id)sender
{
    [self clearMapContents];
    self.mapView.hidden = NO;
    for (Country* country in self.store.countries) {
        [self.mapView addOverlays:country.polygons];
        [self.mapView addAnnotation:country];
    }
}

- (IBAction)showStationsOverlay:(id)sender
{
    [self clearMapContents];
    self.mapView.hidden = NO;
    [self.mapView addOverlay:self.store];
}

- (IBAction)showBetterClusters:(id)sender
{
    [self clearMapContents];
    self.adClusterMapView.hidden = NO;
    [self.adClusterMapView setAnnotations:self.store.stations];
}

// MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if(mapView.hidden==NO) {
        if(mapView==self.mapView) {
            self.adClusterMapView.visibleMapRect = mapView.visibleMapRect;
        } else {
            self.mapView.visibleMapRect = mapView.visibleMapRect;
        }
    }
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass:CCHMapClusterAnnotation.class]){
        [(CCHMapClusterAnnotation*)annotation setDelegate:self];
    }
    MKPinAnnotationView * view = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"MapClusters"];
    if(nil==view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapClusters"];
    }
    BOOL isCluster = NO;
    if([annotation isKindOfClass:CCHMapClusterAnnotation.class]
       && [(CCHMapClusterAnnotation *)annotation isCluster]) {
        isCluster = YES;
    }
    if([annotation isKindOfClass:ADClusterAnnotation.class]
       && [(ADClusterAnnotation*)annotation type]==ADClusterAnnotationTypeCluster){
        isCluster = YES;
    }
    if([annotation isKindOfClass:Country.class]) {
        isCluster = YES;
    }

    if (isCluster) {
        view.image = [NSImage imageNamed:@"cluster"];
    } else {
        view.image = [NSImage imageNamed:@"station"];
    }
    
    view.canShowCallout = YES;
    return view;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    if([overlay isKindOfClass:MKPolygon.class]) {
        MKPolygonRenderer * renderer = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = NSColor.grayColor;
        renderer.lineWidth = 1;
        return renderer;
    } else {
        return [[StationsOverlayRenderer alloc] initWithOverlay:overlay];
    }
}

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController titleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    if (!mapClusterAnnotation.isCluster) {
        return [[mapClusterAnnotation.annotations anyObject] title];
    } else {
        return nil;
    }
}

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController subtitleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    if (!mapClusterAnnotation.isCluster) {
        return [[mapClusterAnnotation.annotations anyObject] subtitle];
    } else {
        return nil;
    }
}

- (NSInteger)numberOfClustersInMapView:(ADClusterMapView *)mapView
{
    return 100;
}

@end


