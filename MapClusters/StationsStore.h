@import Foundation;
@class Station;
@class Country;

@interface StationsStore : NSObject
- (instancetype)initWithCSV:(NSURL*)url;
@property (readonly) NSArray<Station*>* stations;
@property (readonly) NSArray<Country*>* countries;
@end
