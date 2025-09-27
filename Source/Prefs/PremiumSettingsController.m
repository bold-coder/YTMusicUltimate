#import "PremiumSettingsController.h"
#import "../Headers/Localization.h"

// Define the suite name to ensure consistency with LyricsManager
#define LYRICS_DEFAULTS_SUITE @"com.ps.ytmusicultimate"

// Class extension to hold our new text field property
@interface PremiumSettingsController ()
@property (nonatomic, strong) UITextField *tokenTextField;
@end

@implementation PremiumSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = LOC(@"PREMIUM_SETTINGS");
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
}

#pragma mark - Table view stuff
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; // Increased to 2 sections
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2; // For the toggles
    }
    return 1; // For the token field
}

// Add titles for our new sections
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Musixmatch Lyrics";
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return @"Get your token from lrms.main.my.id. This allows the tweak to fetch premium and synced lyrics.";
    }
    return nil;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    if (indexPath.section == 0) {
        // --- Existing code for toggles ---
        NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"]];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell1"];
        
        NSArray *settingsData = @[
            @{@"title": LOC(@"NO_ADS"), @"desc": LOC(@"NO_ADS_DESC"), @"key": @"noAds"},
            @{@"title": LOC(@"BACKGROUND_PLAYBACK"), @"desc": LOC(@"BACKGROUND_PLAYBACK_DESC"), @"key": @"backgroundPlayback"}
        ];

        NSDictionary *data = settingsData[indexPath.row];

        cell.textLabel.text = data[@"title"];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.text = data[@"desc"];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];

        UISwitch *switchControl = [[UISwitch alloc] init];
        switchControl.onTintColor = [UIColor colorWithRed:30.0/255.0 green:150.0/255.0 blue:245.0/255.0 alpha:1.0];
        [switchControl addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
        switchControl.tag = indexPath.row;
        switchControl.on = [YTMUltimateDict[data[@"key"]] boolValue];
        cell.accessoryView = switchControl;
    } else if (indexPath.section == 1) {
        // --- New code for the token text field ---
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tokenCell"];
        cell.textLabel.text = @"User Token";

        // Initialize and configure the text field
        self.tokenTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.5, 30)];
        self.tokenTextField.placeholder = @"Paste your token here";
        self.tokenTextField.textAlignment = NSTextAlignmentRight;

        // Load the saved token
        NSUserDefaults *lyricsPrefs = [[NSUserDefaults alloc] initWithSuiteName:LYRICS_DEFAULTS_SUITE];
        self.tokenTextField.text = [lyricsPrefs stringForKey:@"musixmatchUserToken"];
        
        // Add a target to save the text when it changes
        [self.tokenTextField addTarget:self action:@selector(tokenTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

        cell.accessoryView = self.tokenTextField;
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // Make the token cell un-selectable, but the toggles remain as they were
    if (indexPath.section == 1) {
        return NO;
    }
    return NO;
}

// New method to save the token when the text field changes
- (void)tokenTextFieldDidChange:(UITextField *)sender {
    NSUserDefaults *lyricsPrefs = [[NSUserDefaults alloc] initWithSuiteName:LYRICS_DEFAULTS_SUITE];
    [lyricsPrefs setObject:sender.text forKey:@"musixmatchUserToken"];
    // Post a notification so LyricsManager can reload the token immediately
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.ps.ytmusicultimate/preferences.changed", NULL, NULL, YES);
}

- (void)toggleSwitch:(UISwitch *)sender {
    NSArray *settingsData = @[
        @{@"key": @"noAds"},
        @{@"key": @"backgroundPlayback"},
        @{@"key": @"premiumWorkaround"},
    ];

    NSDictionary *data = settingsData[sender.tag];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];

    [YTMUltimateDict setObject:@([sender isOn]) forKey:data[@"key"]];
    [defaults setObject:YTMUltimateDict forKey:@"YTMUltimate"];
}

@end
