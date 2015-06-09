//
//  STMSideMenuController.h
//  Pods
//
//  Created by Stefano Mondino on 09/06/15.
//
//

#import <UIKit/UIKit.h>
@class STMSideMenuController;
@interface UIViewController(STMSideMenuController)
@property (nonatomic,readonly) STMSideMenuController* sideMenuController;
@end

@interface UIView (STMSideMenuController)
- (void)stm_centerInSuperview;
@end

@interface STMSideMenuMainSegue : UIStoryboardSegue
@end
@interface STMSideMenuLeftSegue : UIStoryboardSegue
@end
@interface STMSideMenuRightSegue : UIStoryboardSegue
@end

@interface STMSideMenuController : UIViewController
@property (nonatomic,strong) UIViewController* mainViewController;
@property (nonatomic,strong) UIViewController* leftViewController;
@property (nonatomic,strong) UIViewController* rightViewController;
@property (nonatomic,readonly) CGFloat leftNWOpen;
@property (nonatomic,readonly) CGFloat leftNWClosed;
@property (nonatomic,readonly) CGFloat rightNWOpen;
@property (nonatomic,readonly) CGFloat rightNWClosed;
- (void) showLeftViewController;
- (void) hideLeftViewController;
- (void) showRightViewController;
- (void) hideRightViewController;
@end
