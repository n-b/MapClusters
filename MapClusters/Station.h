@import Foundation;
@import MapKit;

@interface Station : NSObject <MKAnnotation>
@property CLLocationDegrees latitude;
@property CLLocationDegrees longitude;
@property (copy) NSString * name;
@property (copy) NSString * country;


- (CLLocationCoordinate2D)coordinate;
- (NSString *)title;
@end
