@import Foundation;
@import MapKit;

@class Station;

@interface Country : NSObject <MKAnnotation>
@property NSArray<Station*>* stations;
@property (copy) NSString* name;

@property (nonatomic, readonly) NSArray<MKPolygon*>* polygons;
@end
