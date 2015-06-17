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
    STMAnimationCircularReveal,
    STMAnimationSlideUp,
    STMAnimationCustom,
    STMAnimationNone
} STMSideMenuAnimations;

@class STMSideMenuController;

@interface UIViewController(STMSideMenuController)
@property (nonatomic,readonly) STMSideMenuController* sideMenuController;
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
@property (nonatomic,assign) CGFloat leftWidth;
@property (nonatomic,assign) CGFloat rightWidth;
@property (nonatomic,assign) CGFloat shadowViewAlpha;
@property (nonatomic,strong) UIColor* shadowViewColor;
@property (nonatomic,assign) CGFloat sideAnimationDuration;
@property (nonatomic,assign) CGFloat mainAnimationDuration;

- (void)setMainViewController:(UIViewController *)mainViewController animated:(BOOL) animated;
- (void) showLeftViewControllerAnimated:(BOOL) animated;
- (void) hideLeftViewControllerAnimated:(BOOL) animated;
- (void) showRightViewControllerAnimated:(BOOL) animated;
- (void) hideRightViewControllerAnimated:(BOOL) animated;

/** Define a custom transition between views */
- (void) customAnimationFromView:(UIView*) fromView toView:(UIView*) toView completion:(void (^)(BOOL))completion;

@end
