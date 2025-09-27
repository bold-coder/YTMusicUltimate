#import "LyricsManager.h"
#import <os/log.h>

#define LYRICS_DEFAULTS_SUITE @"com.ps.ytmusicultimate"

@interface LyricsManager()
@property (nonatomic, copy) NSString *userToken;
@end

@implementation LyricsManager

+ (instancetype)sharedInstance {
    static LyricsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadToken];
        // Listen for changes in preferences
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        (__bridge const void *)(self),
                                        preferencesChanged,
                                        (CFStringRef)@"com.ps.ytmusicultimate/preferences.changed",
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
    }
    return self;
}

// C function to handle the notification
static void preferencesChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    os_log(OS_LOG_DEFAULT, "YTMusicUltimate: Lyrics preferences changed, reloading token.");
    [(__bridge LyricsManager *)observer loadToken];
}

- (void)loadToken {
    NSUserDefaults *lyricsPrefs = [[NSUserDefaults alloc] initWithSuiteName:LYRICS_DEFAULTS_SUITE];
    self.userToken = [lyricsPrefs stringForKey:@"musixmatchUserToken"];
    os_log(OS_LOG_DEFAULT, "YTMusicUltimate: Loaded Musixmatch token.");
}

- (void)fetchLyricsForSong:(NSString *)songTitle artist:(NSString *)artistName completion:(void (^)(NSString *lyrics, NSError *error))completion {
    if (!self.userToken || self.userToken.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(@"Musixmatch token not found. Please add one in YTMusicUltimate settings.", nil);
        });
        return;
    }

    NSString *trackString = [songTitle stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *artistString = [artistName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    // Use the new, working API endpoint
    NSString *urlString = [NSString stringWithFormat:@"https://apic.musixmatch.com/ws/1.1/macro.subtitles.get?format=json&namespace=lyrics_synched&q_album=&q_artist=%@&q_artists=%@&q_track=%@&track_spotify_id=&user_language=en&user_token=%@", artistString, artistString, trackString, self.userToken];
    NSURL *url = [NSURL URLWithString:urlString];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"Mozilla/5.0" forHTTPHeaderField:@"User-Agent"];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }

        NSError *jsonError;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, jsonError);
            });
            return;
        }
        
        NSString *lyricsBody = jsonResponse[@"message"][@"body"][@"macro_calls"][@"track.subtitles.get"][@"message"][@"body"][@"subtitles_list"][0][@"subtitle"][@"subtitle_body"];
        
        if (lyricsBody && lyricsBody.length > 0) {
            NSData *lyricsData = [lyricsBody dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *timedLines = [NSJSONSerialization JSONObjectWithData:lyricsData options:0 error:nil];
            
            NSMutableString *formattedLyrics = [NSMutableString new];
            for (NSDictionary *line in timedLines) {
                [formattedLyrics appendFormat:@"%@\n", line[@"text"]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([formattedLyrics stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], nil);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(@"Lyrics not found.", nil);
            });
        }
    }] resume];
}

- (void)dealloc {
    // Clean up observer
    CFNotificationCenterRemoveEveryObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self));
}

@end

