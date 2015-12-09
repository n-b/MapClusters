@import Foundation;
@class Station;

@interface StationsStore : NSObject
- (instancetype)initWithCSV:(NSURL*)url;
@property (readonly) NSArray<Station*>* stations;
@end
