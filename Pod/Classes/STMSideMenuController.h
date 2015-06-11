//
//  STMSideMenuController.h
//  Pods
//
//  Created by Stefano Mondino on 09/06/15.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    STMAnimationAlpha,
    STMAnimationCircularReveal
} STMSideMenuAnimations;

@class STMSideMenuController;
@interface UIViewController(STMSideMenuController)
@property (nonatomic,readonly) STMSideMenuController* sideMenuController;
@end

@interface UIView (STMSideMenuController)

- (void)stm_centerInSuperview;
- (NSLayoutConstraint*) alignLeftWithWidth:(CGFloat) width ;
- (NSLayoutConstraint*) alignRightWithWidth:(CGFloat) width;
@end

@interface STMSideMenuMainSegue : UIStoryboardSegue
@end
@interface STMSideMenuLeftSegue : UIStoryboardSegue
@end
@interface STMSideMenuRightSegue : UIStoryboardSegue
@end

@interface STMSideMenuController : UIViewController
@property (nonatomic,assign) STMSideMenuAnimations animationType;
@property (nonatomic,strong) UIViewController* mainViewController;
@property (nonatomic,strong) UIViewController* leftViewController;
@property (nonatomic,strong) UIViewController* rightViewController;
@property (nonatomic,readonly) CGFloat leftOpenPosition;
@property (nonatomic,readonly) CGFloat leftClosedPosition;
@property (nonatomic,readonly) CGFloat leftWidth;
@property (nonatomic,readonly) CGFloat rightOpenPosition;
@property (nonatomic,readonly) CGFloat rightClosedPosition;
@property (nonatomic,readonly) CGFloat rightWidth;
- (void)setMainViewController:(UIViewController *)mainViewController animated:(BOOL) animated;
- (void) showLeftViewControllerAnimated:(BOOL) animated;
- (void) hideLeftViewControllerAnimated:(BOOL) animated;
- (void) showRightViewControllerAnimated:(BOOL) animated;
- (void) hideRightViewControllerAnimated:(BOOL) animated;
@end
