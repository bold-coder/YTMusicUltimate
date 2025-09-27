#import "LyricsViewController.h"

@interface LyricsViewController ()
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *artistLabel;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@end

@implementation LyricsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup blur background
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.frame = self.view.bounds;
    self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.blurView];
    
    // Setup Title Label
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, self.view.frame.size.width - 40, 30)];
    self.titleLabel.text = self.songTitle;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.blurView.contentView addSubview:self.titleLabel];

    // Setup Artist Label
    self.artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 95, self.view.frame.size.width - 40, 20)];
    self.artistLabel.text = self.artistName;
    self.artistLabel.textColor = [UIColor lightGrayColor];
    self.artistLabel.font = [UIFont systemFontOfSize:18.0];
    self.artistLabel.textAlignment = NSTextAlignmentCenter;
    [self.blurView.contentView addSubview:self.artistLabel];

    // Setup Text View
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 130, self.view.frame.size.width - 20, self.view.frame.size.height - 180)];
    self.textView.text = self.lyricsText;
    self.textView.textColor = [UIColor whiteColor];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.font = [UIFont systemFontOfSize:16.0];
    self.textView.editable = NO;
    [self.blurView.contentView addSubview:self.textView];
    
    // Setup Close Button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    closeButton.frame = CGRectMake(self.view.frame.size.width / 2 - 50, self.view.frame.size.height - 60, 100, 40);
    closeButton.tintColor = [UIColor whiteColor];
    closeButton.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
    closeButton.layer.cornerRadius = 20;
    [self.blurView.contentView addSubview:closeButton];
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
