#import "YTMUltimateSettingsController.h"
#import "PremiumSettingsController.h"
#import "PlayerSettingsController.h"
#import "ThemeSettingsController.h"
#import "NavBarSettingsController.h"
#import "TabBarSettingsController.h"
#import "../Headers/Localization.h"
#import <os/log.h>

#define LYRICS_DEFAULTS_SUITE @"com.ps.ytmusicultimate"

// Class extension to hold our new text field property
@interface YTMUltimateSettingsController ()
@property (nonatomic, strong) UITextField *tokenTextField;
@end

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
    return 5; // Increased from 4 to 5
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return @"Musixmatch Lyrics";
    }
    if (section == 4) {
        return LOC(@"LINKS");
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return LOC(@"RESTART_FOOTER");
    } 
    if (section == 2) {
        return @"Get your token from lrms.main.my.id. This allows the tweak to fetch premium and synced lyrics.";
    }
    if (section == 4) {
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
        case 0: return 1; // Enable/Disable
        case 1: return 5; // Settings links
        case 2: return 1; // NEW: Lyrics Token
        case 3: return 1; // Clear Cache
        case 4: return 4; // Links
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

    if (indexPath.section == 0) {
        // --- Section 0: Enable/Disable ---
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"masterSection"];
        NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"]];
        cell.textLabel.text = LOC(@"ENABLED");
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.textColor = [UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0];
        cell.imageView.image = [UIImage systemImageNamed:@"power"];
        cell.imageView.tintColor = [UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0];
        UISwitch *masterSwitch = [[UISwitch alloc] init];
        masterSwitch.onTintColor = [UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0];
        [masterSwitch addTarget:self action:@selector(toggleMasterSwitch:) forControlEvents:UIControlEventValueChanged];
        masterSwitch.on = [YTMUltimateDict[@"YTMUltimateIsEnabled"] boolValue];
        cell.accessoryView = masterSwitch;
        return cell;
    }

    if (indexPath.section == 1) {
        // --- Section 1: Settings Links ---
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
        cell.detailTextLabel.numberOfLines = 0;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage systemImageNamed:settingData[@"image"]];
        return cell;
    }
    
    if (indexPath.section == 2) {
        // --- Section 2: NEW Lyrics Token Field ---
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tokenCell"];
        cell.textLabel.text = @"User Token";

        self.tokenTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.5, 30)];
        self.tokenTextField.placeholder = @"Paste your token here";
        self.tokenTextField.textAlignment = NSTextAlignmentRight;

        NSUserDefaults *lyricsPrefs = [[NSUserDefaults alloc] initWithSuiteName:LYRICS_DEFAULTS_SUITE];
        self.tokenTextField.text = [lyricsPrefs stringForKey:@"musixmatchUserToken"];
        [self.tokenTextField addTarget:self action:@selector(tokenTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        cell.accessoryView = self.tokenTextField;
        return cell;
    }

    if (indexPath.section == 3) {
        // --- Section 3: Clear Cache ---
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cacheSection"];
        cell.textLabel.text = LOC(@"CLEAR_CACHE");
        UILabel *cache = [[UILabel alloc] init];
        cache.text = [self getCacheSize];
        cache.textColor = [UIColor secondaryLabelColor];
        cache.font = [UIFont systemFontOfSize:16];
        cache.textAlignment = NSTextAlignmentRight;
        [cache sizeToFit];
        cell.accessoryView = cache;
        cell.imageView.image = [UIImage systemImageNamed:@"trash"];
        cell.imageView.tintColor = [UIColor redColor];
        return cell;
    }

    if (indexPath.section == 4) {
        // --- Section 4: Links ---
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
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.text = settingData[@"detail"];
        cell.detailTextLabel.numberOfLines = 0;
        UIImage *image = [UIImage imageNamed:settingData[@"image"]];
        cell.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
        return cell;
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
    // Make enable and token cells non-selectable
    if (indexPath.section == 0 || indexPath.section == 2) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSArray *controllers = @[[PremiumSettingsController class],
                                 [PlayerSettingsController class],
                                 [ThemeSettingsController class],
                                 [NavBarSettingsController class],
                                 [TabBarSettingsController class]]; // Corrected this, was OtherSettingsController before

        if (indexPath.row >= 0 && indexPath.row < controllers.count) {
            UIViewController *controller = [[controllers[indexPath.row] alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }

    if (indexPath.section == 3 && indexPath.row == 0) { // Updated section index
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        activityIndicator.color = [UIColor labelColor];
        [activityIndicator startAnimating];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryView = activityIndicator;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
            [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationNone]; // Updated section index
            });
        });
    }

    if (indexPath.section == 4) { // Updated section index
        NSArray *urls = @[@"https://twitter.com/ginsudev",
                          @"https://twitter.com/dayanch96",
                          @"https://discord.gg/VN9ZSeMhEW",
                          @"https://github.com/dayanch96/YTMusicUltimate"];

        if (indexPath.row >= 0 && indexPath.row < urls.count) {
            NSURL *url = [NSURL URLWithString:urls[indexPath.row]];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Nav bar and Actions
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] performSelector:@selector(suspend)];
            [NSThread sleepForTimeInterval:1.0];
            exit(0);
        });
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)toggleMasterSwitch:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];
    [YTMUltimateDict setObject:@([sender isOn]) forKey:@"YTMUltimateIsEnabled"];
    [defaults setObject:YTMUltimateDict forKey:@"YTMUltimate"];
}

// New method to save the token when the text field changes
- (void)tokenTextFieldDidChange:(UITextField *)sender {
    NSUserDefaults *lyricsPrefs = [[NSUserDefaults alloc] initWithSuiteName:LYRICS_DEFAULTS_SUITE];
    [lyricsPrefs setObject:sender.text forKey:@"musixmatchUserToken"];
    // Post a notification so LyricsManager can reload the token immediately
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.ps.ytmusicultimate/preferences.changed", NULL, NULL, YES);
}

@end
