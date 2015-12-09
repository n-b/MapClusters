#import "MapVC.h"
@import MapKit;

@interface MapVC()
@property IBOutlet MKMapView * mapView;
@end

@implementation MapVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

@end
