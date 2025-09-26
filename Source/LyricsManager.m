#import "LyricsManager.h"

// IMPORTANT: Paste your Musixmatch API key here
static NSString * const musixmatchApiKey = @"PASTE_YOUR_API_KEY_HERE";

@implementation LyricsManager

+ (instancetype)sharedInstance {
    static LyricsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)fetchLyricsForSong:(NSString *)songTitle artist:(NSString *)artistName completion:(void (^)(NSString *lyrics, NSError *error))completion {
    if (musixmatchApiKey.length == 0 || [musixmatchApiKey isEqualToString:@"PASTE_YOUR_API_KEY_HERE"]) {
        completion(@"No API key provided. Please add one in LyricsManager.m", nil);
        return;
    }

    NSString *trackString = [songTitle stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *artistString = [artistName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSString *urlString = [NSString stringWithFormat:@"https://api.musixmatch.com/ws/1.1/matcher.lyrics.get?q_track=%@&q_artist=%@&apikey=%@", trackString, artistString, musixmatchApiKey];
    NSURL *url = [NSURL URLWithString:urlString];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
        
        NSString *lyricsBody = jsonResponse[@"message"][@"body"][@"lyrics"][@"lyrics_body"];
        
        // Remove the Musixmatch disclaimer
        if ([lyricsBody containsString:@"*******"]) {
            lyricsBody = [[lyricsBody componentsSeparatedByString:@"*******"] firstObject];
        }
        
        if (lyricsBody && lyricsBody.length > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(lyricsBody, nil);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(@"Lyrics not found.", nil);
            });
        }
    }] resume];
}

@end
