#import <UIKit/UIKit.h>
#import "../Headers/Localization.h"

@interface TabBarSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end
