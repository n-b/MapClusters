#import "StationsImporter.h"
#import "CHCSVParser.h"
#import "Station.h"

@interface StationsImporter () <CHCSVParserDelegate>
@end

@implementation StationsImporter
{
    CHCSVParser * _parser;
    CHCSVWriter * _writer;
    NSMutableArray<NSString*> * _keys;
    BOOL _firstLine;
    NSMutableDictionary<NSString*,NSString*> * _values;
}
- (instancetype)initWithCSV:(NSURL*)url
{
    self = [super init];
    NSString * cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"stations-clean.csv"];
    if(NSEvent.modifierFlags & NSAlternateKeyMask) {
        [NSFileManager.defaultManager removeItemAtPath:cachePath error:NULL];
    }
    if([NSFileManager.defaultManager fileExistsAtPath:cachePath isDirectory:NULL]) {
        url = [NSURL fileURLWithPath:cachePath];
        _parser = [[CHCSVParser alloc] initWithContentsOfCSVURL:url];
        _parser.delegate = self;
    } else {
        NSStringEncoding encoding = NSUTF8StringEncoding;
        NSInputStream *stream = [NSInputStream inputStreamWithURL:url];
        _parser = [[CHCSVParser alloc] initWithInputStream:stream usedEncoding:&encoding delimiter:';'];
        _parser.delegate = self;
        _writer = [[CHCSVWriter alloc] initForWritingToCSVFile:cachePath];
    }
    
    
    return self;
}

- (void)import
{
    [_parser parse];
}

- (void)parserDidBeginDocument:(CHCSVParser *)parser
{
    _firstLine = YES;
}

- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber
{
    if (_firstLine) {
        // first line
        _keys = [NSMutableArray new];
    } else {
        _values = [NSMutableDictionary new];
    }
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex
{
    if(_firstLine) {
        _keys[fieldIndex] = field;
    } else {
        _values[_keys[fieldIndex]] = field;
    }
}

- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber
{
    if(_firstLine) {
        _firstLine = NO;
        [_writer writeLineOfFields:@[@"latitude", @"longitude", @"name"]];
    } else {
        Station * station = [Station new];
        station.latitude = _values[@"latitude"].doubleValue;
        station.longitude = _values[@"longitude"].doubleValue;
        station.name = _values[@"name"];
        [_writer writeLineOfFields:@[_values[@"latitude"], _values[@"longitude"], _values[@"name"]]];
        [self.delegate importer:self didFindStation:station];
    }
}

- (void)parserDidEndDocument:(CHCSVParser *)parser
{
    [_writer writeLineOfFields:@[_values[@"latitude"], _values[@"longitude"], _values[@"name"]]];
    [self.delegate importerDidFinish:self];
}

@end
