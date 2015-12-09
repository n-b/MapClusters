@import Foundation;
@import MapKit;
@class Station;
@class Country;

@interface StationsStore : NSObject <MKOverlay>
- (instancetype)initWithCSV:(NSURL*)url;
@property (readonly) NSArray<Station*>* stations;
@property (readonly) NSArray<Country*>* countries;
@end
