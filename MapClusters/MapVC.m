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

typedef NS_ENUM(NSInteger, MapMode) {
    MapModeStationsInvalid,
    MapModeStationsAnnotations,
    MapModeQuadtreeClusters,
    MapModeBetterClusters,
    MapModeCountriesOverlays,
    MapModeStationsOverlay,
};
@property (nonatomic) MapMode mode;
@property BOOL autoMode;
@property NSTimer * autoTimer;
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
    [self showBestView:nil];
}

- (IBAction)showStationsAnnotations:(id)sender
{
    self.autoMode = NO;
    self.mode = MapModeStationsAnnotations;
}

- (IBAction)showQuadtreeClusters:(id)sender
{
    self.autoMode = NO;
    self.mode = MapModeQuadtreeClusters;
}

- (IBAction)showBetterClusters:(id)sender
{
    self.autoMode = NO;
    self.mode = MapModeBetterClusters;
}

- (IBAction)showCountriesOverlays:(id)sender
{
    self.autoMode = NO;
    self.mode = MapModeCountriesOverlays;
}

- (IBAction)showStationsOverlay:(id)sender
{
    self.autoMode = NO;
    self.mode = MapModeStationsOverlay;
}

- (IBAction)showBestView:(id)sender
{
    self.autoMode = YES;

    MKZoomScale zoomScale = self.mapView.visibleMapRect.size.width / self.mapView.bounds.size.width;
    NSInteger zoomLevel = 20 - ceil(log2(zoomScale));
    if(zoomLevel>8) {
        self.mode = MapModeStationsAnnotations;
    } else if(zoomLevel>5) {
        self.mode = MapModeStationsOverlay;
    } else {
        self.mode = MapModeCountriesOverlays;
    }
}

- (void) setMode:(MapMode)mode
{
    if (_mode==mode) {
        return;
    }
    
    _mode = mode;

    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    [_mapClusterController removeAnnotations:self.store.stations withCompletionHandler:NULL];

    if(_mode==MapModeBetterClusters) {
        self.mapView.hidden = YES;
        self.adClusterMapView.hidden = NO;
    } else {
        self.mapView.hidden = NO;
        self.adClusterMapView.hidden = YES;
    }
    
    switch (_mode) {
        case MapModeStationsAnnotations:
            [self.mapView addAnnotations:self.store.stations];
            break;
        case MapModeQuadtreeClusters:
            [self.mapClusterController addAnnotations:self.store.stations withCompletionHandler:NULL];
            break;
        case MapModeBetterClusters:
            [self.adClusterMapView setAnnotations:self.store.stations];
            break;
        case MapModeCountriesOverlays:
            for (Country* country in self.store.countries) {
                [self.mapView addOverlays:country.parts];
                [self.mapView addAnnotation:country];
            }
            break;
        case MapModeStationsOverlay:
            [self.mapView addOverlay:self.store];
            break;
        default:
            break;
    }
}

// MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if(self.autoMode) {
        self.autoTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showBestView:) userInfo:nil repeats:YES];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self.autoTimer invalidate];
    self.autoTimer = nil;
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
        MKAnnotationView * view = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"cluster"];
        if(nil==view) {
            view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"cluster"];
            view.image = [NSImage imageNamed:@"cluster"];
            view.canShowCallout = YES;
        }
        return view;
    } else {
        MKPinAnnotationView * view = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"station"];
        if(nil==view) {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"station"];
            view.pinTintColor = [NSColor colorWithRed:63/255. green:174/255. blue:42/255. alpha:1];
            view.canShowCallout = YES;
        }
        return view;
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    if([overlay isKindOfClass:CountryPart.class]) {
        MKPolygonRenderer * renderer = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = [NSColor.grayColor colorWithAlphaComponent:.1];
        renderer.lineWidth = 1;
        Country * country = [(CountryPart*)overlay country];
        NSColor * color = [NSColor colorWithRed:63/255. green:174/255. blue:42/255. alpha:1];
        if(country.stations.count>1000) {
            renderer.fillColor = [color colorWithAlphaComponent:.3];
        } else if(country.stations.count>10) {
            renderer.fillColor = [color colorWithAlphaComponent:.2];
        } else {
            renderer.fillColor = [color colorWithAlphaComponent:.1];
        }
        return renderer;
    } else if([overlay isKindOfClass:StationsStore.class]) {
        return [[StationsOverlayRenderer alloc] initWithOverlay:overlay];
    } else {
        return nil;
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


