@import Foundation;
@import MapKit;

@class Station;
@class CountryPart;

@interface Country : NSObject <MKAnnotation>
@property NSArray<Station*>* stations;
@property (copy) NSString* name;

@property (nonatomic, readonly) NSArray<CountryPart*>* parts;
@end


@interface CountryPart : MKPolygon
@property (weak, readonly) Country* country;
@property (readonly) MKPolygon* polygon;
@end