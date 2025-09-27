#import <Foundation/Foundation.h>

@interface LyricsManager : NSObject

+ (instancetype)sharedInstance;

- (void)fetchLyricsForSong:(NSString *)songTitle 
                    artist:(NSString *)artistName 
                completion:(void (^)(NSString *lyrics, NSError *error))completion;

@end
