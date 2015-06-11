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
    [self.sideMenuController showLeftViewControllerAnimated:YES];
}
- (IBAction)showRightMenu:(id)sender {
    [self.sideMenuController showRightViewControllerAnimated:YES];
}
@end

@interface STMSideMenuController () <UIGestureRecognizerDelegate>
@property (nonatomic,weak) UIView* shadowView;
@property (nonatomic,strong) UIPanGestureRecognizer* leftPanGesture;
@property (nonatomic,strong) UIPanGestureRecognizer* rightPanGesture;
@property (nonatomic,weak) UIView* panningView;
@property (nonatomic,assign) CGFloat panningPadding;
@property (nonatomic,weak) NSLayoutConstraint* leftConstraint;
@property (nonatomic,weak) NSLayoutConstraint* rightConstraint;
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
/*
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    if (self.leftViewController){
        [self.leftViewController.view updateConstraints];
        if (self.isLeftOpen) [self showLeftViewControllerAnimated:YES];
        else [self hideLeftViewControllerAnimated:YES];
    }
    if (self.rightViewController){
        (self.isRightOpen) ? [self showRightViewControllerAnimated:YES]:[self hideRightViewControllerAnimated:YES];
    }
}
*/
- (void) handlePan:(UIPanGestureRecognizer*) panGesture {
    CGFloat velocity = [panGesture velocityInView:panGesture.view].x;
    UIScreenEdgePanGestureRecognizer* edge = [panGesture isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]?(UIScreenEdgePanGestureRecognizer*)panGesture:nil;
    BOOL isLeft = _panningView == self.leftViewController.view || edge.edges == UIRectEdgeLeft ;

    if (panGesture.state == UIGestureRecognizerStateBegan) {
        
        if (!self.isLeftOpen && !self.isRightOpen) {
            _panningView = isLeft? self.leftViewController.view : self.rightViewController.view;
           
            self.shadowView.hidden = NO;
            self.shadowView.alpha = 0;
        }
        else {
            _panningView = self.isLeftOpen?self.leftViewController.view : self.rightViewController.view;
        }
         _panningPadding = _panningView.frame.origin.x;
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded) {

        if (!_panningView) return;
        if (velocity > self.view.frame.size.width/3) {
            if (!self.isRightOpen && isLeft){
                [self showLeftViewControllerAnimated:YES];
            }
            else {
                [self hideRightViewControllerAnimated:YES];
            }
        }
        else if (velocity < -self.view.frame.size.width/3) {
            if (!self.isLeftOpen && !isLeft){
                [self showRightViewControllerAnimated:YES];
            }
            else {
                [self hideLeftViewControllerAnimated:YES];
            }
        }
        else {
            if (isLeft) {
                CGFloat pos = (self.leftViewController.view.frame.origin.x - self.leftOpenPosition)/(self.leftWidth-self.leftOpenPosition);
                ABS(pos) > 0.5?[self hideLeftViewControllerAnimated:YES]:[self showLeftViewControllerAnimated:YES];
            }
            else {
                CGFloat pos = (self.rightViewController.view.frame.origin.x - self.rightOpenPosition)/(self.rightClosedPosition-self.rightOpenPosition);
                ABS(pos) > 0.5?[self hideRightViewControllerAnimated:YES]:[self showRightViewControllerAnimated:YES];
            }
        }
        
        _panningView = nil;
    }
    
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        if (!_panningView) return;
        
        
        CGFloat x = [panGesture translationInView:self.view].x;
        
        CGFloat closedNW = isLeft? self.leftClosedPosition:self.rightClosedPosition;
        CGFloat openNW = isLeft? self.leftOpenPosition : self.rightOpenPosition;

        CGRect frame = _panningView.frame;
        CGFloat alpha;
        if (isLeft){
            x =  MAX(self.leftClosedPosition,MIN(x + self.panningPadding,self.leftOpenPosition));
            alpha = (self.shadowViewAlpha* ( self.leftClosedPosition-x)/(self.leftClosedPosition-self.leftOpenPosition));
        }
        else {
            
            x =  MAX(openNW,MIN(x + self.panningPadding,closedNW));
            alpha   = self.shadowViewAlpha - ABS(self.shadowViewAlpha* (x - openNW)/(openNW-closedNW));
        }
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
        [self hideLeftViewControllerAnimated:YES];
    }
    if (self.isRightOpen) {
        [self hideRightViewControllerAnimated:YES];
    }
    
}
- (void)setMainViewController:(UIViewController *)mainViewController {
    [self setMainViewController:mainViewController animated:NO];
}

- (void)setMainViewController:(UIViewController *)mainViewController animated:(BOOL) animated {
    UIViewController* oldController = self.mainViewController;
    if (!oldController) animated = NO;
    _mainViewController = mainViewController;
    [self addChildViewController:mainViewController];
    if (!oldController) {
        [self.view insertSubview:mainViewController.view atIndex:0];
    }
    else {
        [self.view insertSubview:mainViewController.view aboveSubview:oldController.view];
    }
    [self hideLeftViewControllerAnimated:animated];
    [self hideRightViewControllerAnimated:animated];
    void (^completion)(BOOL) = ^(BOOL finished) {
        [oldController.view removeFromSuperview];
        [oldController removeFromParentViewController];
    };
    if (animated) {
        mainViewController.view.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            mainViewController.view.alpha = 1;
        } completion:completion];
    }
    else {
        completion(YES);
    }
    
    [mainViewController.view addGestureRecognizer:self.leftPanGesture];
    [mainViewController.view addGestureRecognizer:self.rightPanGesture];
}

- (void) setLeftViewController:(UIViewController *)leftViewController {
    [self.leftViewController.view removeFromSuperview];
    [self.leftViewController removeFromParentViewController];
    _leftViewController = leftViewController;
    CGFloat w = self.leftWidth;
    [self addChildViewController:leftViewController];
    leftViewController.view.frame = CGRectMake(self.leftClosedPosition, 0, w, self.view.frame.size.height);
    [self.view addSubview:leftViewController.view];
    self.leftConstraint = [leftViewController.view alignLeftWithWidth:w];
    [self hideLeftViewControllerAnimated:NO];
    leftViewController.view.userInteractionEnabled = YES;
    [leftViewController.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
}
- (CGFloat) leftOpenPosition {
    return 0;
}
- (CGFloat) leftClosedPosition {
    return - self.leftWidth;
    //return - MAX(self.view.frame.size.height,self.view.frame.size.width);
}

- (CGFloat) leftWidth {
    return 200;
}

- (CGFloat) rightClosedPosition {
    return self.view.frame.size.width;
}
- (CGFloat) rightOpenPosition {
    return self.view.frame.size.width - [self rightWidth];
}
- (CGFloat) rightWidth {
    return 100;
}

- (BOOL) isLeftOpen {
    return self.leftViewController &&  self.leftViewController.view.frame.origin.x != self.leftClosedPosition;
}


- (BOOL) isRightOpen {
    return self.rightViewController &&  self.rightViewController.view.frame.origin.x != self.rightClosedPosition;
}
- (void) showLeftViewControllerAnimated:(BOOL) animated {
    UIView* view = self.leftViewController.view;
    NSLayoutConstraint* left = self.leftConstraint;
    UIView* shadowView = self.shadowView;
    CGFloat shadowViewAlpha = self.shadowViewAlpha;
    shadowView.hidden = NO;
    CGFloat w = self.leftOpenPosition;
    left.constant = w;
    void (^animation)(void) = ^{
        [view layoutIfNeeded];
        shadowView.alpha = shadowViewAlpha;
    };
    void (^completion)(BOOL) = ^(BOOL finished){

    };
    
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:animation completion:completion];
    }
    else {
        animation();
        completion(YES);
    }
}

- (void) hideLeftViewControllerAnimated:(BOOL) animated {
    UIView* view = self.leftViewController.view;
    NSLayoutConstraint* left = self.leftConstraint;
    UIView* shadowView = self.shadowView;
    CGFloat x = self.leftClosedPosition;
    left.constant = x;
    void (^animation)(void) = ^{
        [view layoutIfNeeded];
        shadowView.alpha = 0;
    };
    void (^completion)(BOOL) = ^(BOOL finished){
        [view setNeedsUpdateConstraints];
        [view updateConstraintsIfNeeded];
        if (finished) shadowView.hidden = YES;
    };
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:animation completion:completion];
    }
    else {
        animation();
        completion(YES);
    }

}

- (void) setRightViewController:(UIViewController *)rightViewController {
    [self.rightViewController.view removeFromSuperview];
    [self.rightViewController removeFromParentViewController];
    _rightViewController = rightViewController;
    CGFloat w = self.rightWidth;
    [self addChildViewController:rightViewController];
    rightViewController.view.frame = CGRectMake(-w, 0, w, self.view.frame.size.height);
    [self.view addSubview:rightViewController.view];
    self.rightConstraint = [rightViewController.view alignRightWithWidth:self.leftWidth];
    [self hideRightViewControllerAnimated:NO];
    rightViewController.view.userInteractionEnabled = YES;
    [rightViewController.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
}

- (void) showRightViewControllerAnimated:(BOOL) animated {
    UIView* view = self.rightViewController.view;
    UIView* shadowView = self.shadowView;
    CGFloat shadowViewAlpha = self.shadowViewAlpha;
    shadowView.hidden = NO;
    CGFloat w = self.view.frame.size.width-self.rightOpenPosition;
    NSLayoutConstraint* right = self.rightConstraint;
    right.constant = w;
    
    void (^animation)(void) = ^{
        [view layoutIfNeeded];
        shadowView.alpha = shadowViewAlpha;
    };
    void (^completion)(BOOL) = ^(BOOL finished){
        ;
    };
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:animation completion:completion];
    }
    else {
        animation();
        completion(YES);
    }
    
}

- (void) hideRightViewControllerAnimated:(BOOL) animated {
    UIView* view = self.rightViewController.view;
    UIView* shadowView = self.shadowView;
    CGFloat w = self.view.frame.size.width-self.rightClosedPosition;
    self.rightConstraint.constant = w;
    void (^animation)(void) = ^{
        [view layoutIfNeeded];
        shadowView.alpha = 0;
    };
    void (^completion)(BOOL) = ^(BOOL finished){
        if (finished) shadowView.hidden = YES;
    };
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:animation completion:completion];
    }
    else {
        animation();
        completion(YES);
    }
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

- (NSLayoutConstraint*) alignLeftWithWidth:(CGFloat) width {
    UIView* containerView = self.superview;
    self.translatesAutoresizingMaskIntoConstraints = NO;

    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:containerView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
    NSLayoutConstraint* left = [NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:containerView
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.0
                                                             constant:-width];
    [containerView addConstraint:left];
    
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:containerView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[self(==%.0f)]",width]
                                                                   options:0
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(self)]];
    return left;
}
- (NSLayoutConstraint*) alignRightWithWidth:(CGFloat) width {
    UIView* containerView = self.superview;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:containerView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
    NSLayoutConstraint* right = [NSLayoutConstraint constraintWithItem:containerView
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.0
                                                             constant:width];
    [containerView addConstraint:right];
    
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:containerView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[self(==%.0f)]",width]
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(self)]];
    return right;
}
@end

@implementation STMSideMenuMainSegue

- (void)perform {
    STMSideMenuController* controller = [self.sourceViewController sideMenuController];
    UIViewController* destination = self.destinationViewController;
    [controller setMainViewController:destination animated:YES];
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
