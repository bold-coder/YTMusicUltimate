#import "YTMUltimateSettingsController.h"
#import "PremiumSettingsController.h"
#import "PlayerSettingsController.h"
#import "ThemeSettingsController.h"
#import "NavBarSettingsController.h"
#import "TabBarSettingsController.h"
#import "../Headers/Localization.h"
#import <os/log.h>

#define LYRICS_DEFAULTS_SUITE @"com.ps.ytmusicultimate"

@implementation YTMUltimateSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"xmark"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(closeButtonTapped:)]; 

    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"checkmark"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(applyButtonTapped:)]; 

    self.navigationItem.leftBarButtonItem = closeButton;
    self.navigationItem.rightBarButtonItem = applyButton;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.tableView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.tableView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
        [self.tableView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor]
    ]];

    //Init isEnabled for first time
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"]];
    if (!YTMUltimateDict[@"YTMUltimateIsEnabled"]) {
        [YTMUltimateDict setObject:@(1) forKey:@"YTMUltimateIsEnabled"];
        [[NSUserDefaults standardUserDefaults] setObject:YTMUltimateDict forKey:@"YTMUltimate"];
    }
}

#pragma mark - Table view stuff
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 2) return @"MUSIXMATCH LYRICS";
    if (section == 4) return LOC(@"LINKS");
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return LOC(@"RESTART_FOOTER");
    } if (section == 4) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];
        return [NSString stringWithFormat:@"\nYouTubeMusic: v%@\nYTMusicUltimate: v%@", appVersion, @(OS_STRINGIFY(TWEAK_VERSION))];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if (section == 4) {
        UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
        footer.textLabel.textAlignment = NSTextAlignmentCenter;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0: return 1;
        case 1: return 5;
        case 2: return 1;
        case 3: return 1;
        case 4: return 4;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    } else {
        for (UIView *subview in cell.contentView.subviews) {
            [subview removeFromSuperview];
        }
    }

    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"]];

    if (indexPath.section == 0) {
        // Master Switch
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"masterSection"];

        cell.textLabel.text = LOC(@"ENABLED");
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.textColor = [UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0];
        cell.imageView.image = [UIImage systemImageNamed:@"power"];
        cell.imageView.tintColor = [UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0];

        UISwitch *masterSwitch = [[NSClassFromString(@"ABCSwitch") alloc] init];
        masterSwitch.onTintColor = [UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0];
        [masterSwitch addTarget:self action:@selector(toggleMasterSwitch:) forControlEvents:UIControlEventValueChanged];
        masterSwitch.on = [YTMUltimateDict[@"YTMUltimateIsEnabled"] boolValue];
        cell.accessoryView = masterSwitch;
    } else if (indexPath.section == 1) {
        // Settings Links
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"settingsSection"];

        NSArray *settingsData = @[
            @{@"title": LOC(@"PREMIUM_SETTINGS"), @"image": @"flame"},
            @{@"title": LOC(@"PLAYER_SETTINGS"), @"image": @"play.rectangle"},
            @{@"title": LOC(@"THEME_SETTINGS"), @"image": @"paintbrush"},
            @{@"title": LOC(@"NAVBAR_SETTINGS"), @"image": @"sidebar.trailing"},
            @{@"title": LOC(@"TABBAR_SETTINGS"), @"image": @"dock.rectangle"}
        ];
        NSDictionary *settingData = settingsData[indexPath.row];

        cell.textLabel.text = settingData[@"title"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage systemImageNamed:settingData[@"image"]];
    } else if (indexPath.section == 2) {
        // Musixmatch Token
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"tokenCell"];
        cell.textLabel.text = @"Musixmatch User Token";
        
        NSUserDefaults *lyricsPrefs = [[NSUserDefaults alloc] initWithSuiteName:LYRICS_DEFAULTS_SUITE];
        NSString *token = [lyricsPrefs stringForKey:@"musixmatchUserToken"];
        
        if (token && token.length > 0) {
            cell.detailTextLabel.text = @"Set";
            cell.detailTextLabel.textColor = [UIColor systemGreenColor];
        } else {
            cell.detailTextLabel.text = @"Not Set";
            cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 3) {
        // Clear Cache
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cacheSection"];
        cell.textLabel.text = LOC(@"CLEAR_CACHE");
        UILabel *cache = [[UILabel alloc] init];
        cache.text = [self getCacheSize];
        cache.textColor = [UIColor secondaryLabelColor];
        [cache sizeToFit];
        cell.accessoryView = cache;
        cell.imageView.image = [UIImage systemImageNamed:@"trash"];
        cell.imageView.tintColor = [UIColor redColor];
    } else if (indexPath.section == 4) {
        // Links
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"linkSection"];
        NSArray *settingsData = @[
            @{@"text": [NSString stringWithFormat:LOC(@"TWITTER"), @"Ginsu"],  @"detail": LOC(@"TWITTER_DESC"), @"image": @"ginsu-24@2x"},
            @{@"text": [NSString stringWithFormat:LOC(@"TWITTER"), @"Dayanch96"], @"detail": LOC(@"TWITTER_DESC"), @"image": @"dayanch96-24@2x"},
            @{@"text": LOC(@"DISCORD"), @"detail": LOC(@"DISCORD_DESC"), @"image": @"discord-24@2x"},
            @{@"text": LOC(@"SOURCE_CODE"), @"detail": LOC(@"SOURCE_CODE_DESC"), @"image": @"github-24@2x"}
        ];
        NSDictionary *settingData = settingsData[indexPath.row];
        cell.textLabel.text = settingData[@"text"];
        cell.textLabel.textColor = [UIColor systemBlueColor];
        cell.detailTextLabel.text = settingData[@"detail"];
        UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.ytmu_defaultBundle pathForResource:settingData[@"image"] ofType:@"png" inDirectory:@"icons"]];
        cell.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }

    return cell;
}

- (NSString *)getCacheSize {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:cachePath error:nil];
    unsigned long long int folderSize = 0;
    for (NSString *fileName in filesArray) {
        NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        folderSize += [fileAttributes fileSize];
    }
    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.countStyle = NSByteCountFormatterCountStyleFile;
    return [formatter stringFromByteCount:folderSize];
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section != 0);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 1) {
        NSArray *controllers = @[
            [PremiumSettingsController class],
            [PlayerSettingsController class],
            [ThemeSettingsController class],
            [NavBarSettingsController class],
            [TabBarSettingsController class]
        ];
        if (indexPath.row < controllers.count) {
            UIViewController *controller = [[controllers[indexPath.row] alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (indexPath.section == 2) {
        [self showTokenAlert];
    } else if (indexPath.section == 3) {
        // Clear Cache Action
    } else if (indexPath.section == 4) {
        NSArray *urls = @[@"https://twitter.com/ginsudev",
                          @"https://twitter.com/dayanch96",
                          @"https://discord.gg/VN9ZSeMhEW",
                          @"https://github.com/dayanch96/YTMusicUltimate"];
        if (indexPath.row < urls.count) {
            NSURL *url = [NSURL URLWithString:urls[indexPath.row]];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
}

#pragma mark - Token Alert & Logic
- (void)showTokenAlert {
    NSUserDefaults *lyricsPrefs = [[NSUserDefaults alloc] initWithSuiteName:LYRICS_DEFAULTS_SUITE];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter User Token"
                                                                   message:@"You need to retrieve your user token.\nTap \"Request Anonymous Token\" to get one automatically, or get your own from lrms.main.my.id and paste it here."
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Musixmatch User Token";
        textField.text = [lyricsPrefs stringForKey:@"musixmatchUserToken"];
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *token = alert.textFields.firstObject.text;
        [lyricsPrefs setObject:token forKey:@"musixmatchUserToken"];
        [lyricsPrefs synchronize];
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.ps.ytmusicultimate/preferences.changed", NULL, NULL, YES);
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Request Anonymous Token" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self requestAnonymousToken];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)requestAnonymousToken {
    NSURL *url = [NSURL URLWithString:@"https://apic-mobile.musixmatch.com/ws/1.1/token.get?app_id=web-desktop-app-v1.0"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self showNetworkErrorAlert];
                return;
            }
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *token = json[@"message"][@"body"][@"user_token"];
            
            if (token && token.length > 0) {
                NSUserDefaults *lyricsPrefs = [[NSUserDefaults alloc] initWithSuiteName:LYRICS_DEFAULTS_SUITE];
                [lyricsPrefs setObject:token forKey:@"musixmatchUserToken"];
                [lyricsPrefs synchronize];
                CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.ps.ytmusicultimate/preferences.changed", NULL, NULL, YES);
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
                [self showTokenSuccessAlert];
            } else {
                [self showNetworkErrorAlert];
            }
        });
    }] resume];
}

- (void)showNetworkErrorAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"A network error occurred." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showTokenSuccessAlert {
     UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Anonymous token has been saved." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Nav bar stuff
- (NSString *)title {
    return @"YTMusicUltimate";
}

- (void)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)applyButtonTapped:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOC(@"WARNING") message:LOC(@"APPLY_MESSAGE") preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"CANCEL") style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"YES") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        exit(0);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)toggleMasterSwitch:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];
    [YTMUltimateDict setObject:@([sender isOn]) forKey:@"YTMUltimateIsEnabled"];
    [defaults setObject:YTMUltimateDict forKey:@"YTMUltimate"];
}

@end

