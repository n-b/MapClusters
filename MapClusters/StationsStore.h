@import Foundation;
@class Station;

@interface StationsStore : NSObject
- (instancetype)initWithCSV:(NSURL*)url;
@property (readonly) NSArray<Station*>* stations;
@property (readonly) NSDictionary<NSString*,NSArray<Station*>*>* countries;
@end
