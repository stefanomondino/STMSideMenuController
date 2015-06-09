//
//  STMSideMenuController.m
//  Pods
//
//  Created by Stefano Mondino on 09/06/15.
//
//

#import "STMSideMenuController.h"



@implementation UIViewController(STMSideMenuController)
- (STMSideMenuController *)sideMenuController {
    UIViewController* parent = self;
    while (parent!=nil) {
        if ([parent isKindOfClass:[STMSideMenuController class]]){
            return (STMSideMenuController*)parent;
        }
        parent = parent.parentViewController;
    }
    return nil;
}
- (IBAction)showLeftMenu:(id)sender {
    [self.sideMenuController showLeftViewController];
}
- (IBAction)showRightMenu:(id)sender {
    [self.sideMenuController showRightViewController];
}
@end

@interface STMSideMenuController () <UIGestureRecognizerDelegate>
@property (nonatomic,weak) UIView* shadowView;
@property (nonatomic,strong) UIPanGestureRecognizer* leftPanGesture;
@property (nonatomic,strong) UIPanGestureRecognizer* rightPanGesture;
@property (nonatomic,weak) UIView* panningView;
@property (nonatomic,assign) CGFloat panningPadding;
@end

@implementation STMSideMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupShadowView];
    
}
- (void) setupShadowView {
    UIView* shadowView = [[UIView alloc] init];
    self.shadowView = shadowView;
    self.shadowView.backgroundColor = self.shadowViewColor;
    self.shadowView.alpha = self.shadowViewAlpha;
    [self.view addSubview:self.shadowView];
    self.shadowView.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideController:)];
    [self.shadowView addGestureRecognizer:tap];
    [self.shadowView stm_centerInSuperview];
}
- (UIColor*) shadowViewColor {
    return [UIColor blackColor] ;
}
- (CGFloat) shadowViewAlpha {
    return 0.5;
}
- (UIPanGestureRecognizer*) leftPanGesture {
    if (!_leftPanGesture) {
        UIScreenEdgePanGestureRecognizer* pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        pan.edges = UIRectEdgeLeft;
        _leftPanGesture = pan;
        _leftPanGesture.delegate = self;
    }
    return _leftPanGesture;
}
- (UIPanGestureRecognizer*) rightPanGesture {
    if (!_rightPanGesture) {
        UIScreenEdgePanGestureRecognizer* pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        pan.edges = UIRectEdgeRight;
        _rightPanGesture = pan;
        _rightPanGesture.delegate = self;
    }
    return _rightPanGesture;
}
- (void) handlePan:(UIPanGestureRecognizer*) panGesture {
    CGFloat velocity = [panGesture velocityInView:panGesture.view].x;
    UIScreenEdgePanGestureRecognizer* edge = [panGesture isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]?(UIScreenEdgePanGestureRecognizer*)panGesture:nil;
    BOOL isLeft = _panningView == self.leftViewController.view || edge.edges == UIRectEdgeLeft ;
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        
        if (!self.isLeftOpen && !self.isRightOpen) {
            _panningView = isLeft? self.leftViewController.view : self.rightViewController.view;
            _panningPadding = isLeft? self.leftNWClosed:self.rightNWClosed;
            self.shadowView.hidden = NO;
            self.shadowView.alpha = 0;
        }
        else {
            _panningView = self.isLeftOpen?self.leftViewController.view : self.rightViewController.view;
            _panningPadding = self.isLeftOpen?self.leftNWOpen : self.rightNWOpen;
        }
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded) {
        if (!_panningView) return;
        if (velocity > self.view.frame.size.width/3) {
            if (!self.isRightOpen && isLeft){
                [self showLeftViewController];
            }
            else {
                [self hideRightViewController];
            }
        }
        else if (velocity < -self.view.frame.size.width/3) {
            if (!self.isLeftOpen && !isLeft){
                [self showRightViewController];
            }
            else {
                [self hideLeftViewController];
            }
        }
        else {
            if (isLeft) {
                CGFloat pos = (self.leftViewController.view.frame.origin.x - self.leftNWOpen)/(self.leftNWClosed-self.leftNWOpen);
                ABS(pos) > 0.5?[self hideLeftViewController]:[self showLeftViewController];
            }
            else {
                CGFloat pos = (self.rightViewController.view.frame.origin.x - self.rightNWOpen)/(self.rightNWClosed-self.rightNWOpen);
                ABS(pos) > 0.5?[self hideRightViewController]:[self showRightViewController];
            }
        }
        
        _panningView = nil;
    }
    
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        if (!_panningView) return;
        
        
        CGFloat x = [panGesture translationInView:self.view].x;
        
        CGFloat closedNW = isLeft? self.leftNWClosed:self.rightNWClosed;
        CGFloat openNW = isLeft? self.leftNWOpen : self.rightNWOpen;
        
        
        CGRect frame = _panningView.frame;
        CGFloat alpha;
        if (isLeft){
        x =  MAX(-closedNW,MIN(x - self.panningPadding,openNW));
        alpha = self.shadowViewAlpha - ABS(self.shadowViewAlpha* (x - closedNW)/(closedNW-openNW));
        }
        else {
        
        x =  MAX(openNW,MIN(x + self.panningPadding,closedNW));
            NSLog(@"%.2f",x);
            
          alpha   = self.shadowViewAlpha - ABS(self.shadowViewAlpha* (x - openNW)/(openNW-closedNW));
        }
        NSLog(@"x: %.2f - alpha: %.2f",x,alpha);
        
        frame.origin.x = x;
        
        self.shadowView.alpha = alpha;
        
        _panningView.frame = frame;
    }
    else {
        _panningView = nil;
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (panGestureRecognizer == self.rightPanGesture && !self.rightViewController) return NO;
    if (panGestureRecognizer == self.leftPanGesture && !self.leftViewController) return NO;
    CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
    return fabs(velocity.y) < fabs(velocity.x);
}


- (void) hideController:(UITapGestureRecognizer* )recognizer {
    if (self.isLeftOpen) {
        [self hideLeftViewController];
    }
    if (self.isRightOpen) {
        [self hideRightViewController];
    }
    
}
- (void)setMainViewController:(UIViewController *)mainViewController {
    [self.mainViewController.view removeFromSuperview];
    [self.mainViewController removeFromParentViewController];
    _mainViewController = mainViewController;
    [self addChildViewController:mainViewController];
    [self.view insertSubview:mainViewController.view atIndex:0];
    [self hideLeftViewController];
    [self hideRightViewController];
    
    [mainViewController.view addGestureRecognizer:self.leftPanGesture];
    [mainViewController.view addGestureRecognizer:self.rightPanGesture];
}

- (void) setLeftViewController:(UIViewController *)leftViewController {
    [self.leftViewController.view removeFromSuperview];
    [self.leftViewController removeFromParentViewController];
    _leftViewController = leftViewController;
    CGFloat w = self.leftNWClosed;
    [self addChildViewController:leftViewController];
    leftViewController.view.frame = CGRectMake(-w, 0, w, self.view.frame.size.height);
    [self.view addSubview:leftViewController.view];
    [self hideLeftViewController];
    leftViewController.view.userInteractionEnabled = YES;
    [leftViewController.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
}
- (CGFloat) leftNWOpen {
    return 0;
}
- (CGFloat) leftNWClosed {
    return self.view.frame.size.width*0.75;
}

- (CGFloat) rightNWClosed {
    return self.view.frame.size.width;
}
- (CGFloat) rightNWOpen {
    return self.view.frame.size.width*0.25;
}


- (BOOL) isLeftOpen {
    return self.leftViewController &&  self.leftViewController.view.frame.origin.x != -self.leftNWClosed;
}

- (BOOL) isRightOpen {
    return self.rightViewController &&  self.rightViewController.view.frame.origin.x == self.rightNWOpen;
}
- (void) showLeftViewController {
    UIView* view = self.leftViewController.view;
    UIView* shadowView = self.shadowView;
    CGFloat shadowViewAlpha = self.shadowViewAlpha;
    shadowView.hidden = NO;
    CGFloat w = self.leftNWOpen;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.frame =CGRectMake(w,0,view.frame.size.width,view.frame.size.height);
        shadowView.alpha = shadowViewAlpha;
    } completion:^(BOOL finished) {
    }];
}

- (void) hideLeftViewController {
    UIView* view = self.leftViewController.view;
    UIView* shadowView = self.shadowView;
    CGFloat w = self.leftNWClosed;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.frame = CGRectMake(-w,0,view.frame.size.width,view.frame.size.height);
        shadowView.alpha = 0;
    } completion:^(BOOL finished) {
         if (finished) shadowView.hidden = YES;
    }];
}

- (void) setRightViewController:(UIViewController *)rightViewController {
    [self.rightViewController.view removeFromSuperview];
    [self.rightViewController removeFromParentViewController];
    _rightViewController = rightViewController;
    CGFloat w = self.leftNWClosed;
    [self addChildViewController:rightViewController];
    rightViewController.view.frame = CGRectMake(-w, 0, w, self.view.frame.size.height);
    [self.view addSubview:rightViewController.view];
    [self hideRightViewController];
    rightViewController.view.userInteractionEnabled = YES;
    [rightViewController.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
}

- (void) showRightViewController {
    UIView* view = self.rightViewController.view;
    UIView* shadowView = self.shadowView;
    CGFloat shadowViewAlpha = self.shadowViewAlpha;
    shadowView.hidden = NO;
    CGFloat w = self.rightNWOpen;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.frame =CGRectMake(w,0,view.frame.size.width,view.frame.size.height);
        shadowView.alpha = shadowViewAlpha;
    } completion:^(BOOL finished) {
    }];
}

- (void) hideRightViewController {
    UIView* view = self.rightViewController.view;
    UIView* shadowView = self.shadowView;
    CGFloat w = self.rightNWClosed;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.frame = CGRectMake(w,0,view.frame.size.width,view.frame.size.height);
        shadowView.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) shadowView.hidden = YES;
    }];
}

@end




@implementation UIView (STMSideMenuController)
- (void)stm_centerInSuperview {
    UIView* containerView = self.superview;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:containerView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:containerView
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:containerView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:containerView
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0
                                                               constant:0.0]];
}
@end

@implementation STMSideMenuMainSegue

- (void)perform {
    STMSideMenuController* controller = [self.sourceViewController sideMenuController];
    UIViewController* destination = self.destinationViewController;
    [controller setMainViewController:destination];
}

@end
@implementation STMSideMenuLeftSegue

- (void)perform {
    STMSideMenuController* controller = [self.sourceViewController sideMenuController];
    UIViewController* destination = self.destinationViewController;
    [controller setLeftViewController:destination];
}

@end
@implementation STMSideMenuRightSegue

- (void)perform {
    STMSideMenuController* controller = [self.sourceViewController sideMenuController];
    UIViewController* destination = self.destinationViewController;
    [controller setRightViewController:destination];
}

@end
