@import Foundation;
@class Station;
@protocol StationsImporterDelegate;

@interface StationsImporter : NSObject
- (instancetype)initWithCSV:(NSURL*)url;
@property (weak) id<StationsImporterDelegate> delegate;
- (void) import;
@end

@protocol StationsImporterDelegate <NSObject>
- (void) importer:(StationsImporter*)importer_ didFindStation:(Station*)station_;
- (void) importerDidFinish:(StationsImporter*)importer_;
@end

