//
//  STMSideMenuController.m
//  Pods
//
//  Created by Stefano Mondino on 09/06/15.
//
//

#import "STMSideMenuController.h"

@interface UIView (STMSideMenuController)

- (void)stm_centerInSuperview;
- (NSLayoutConstraint*) stm_alignLeftWithWidth:(CGFloat) width ;
- (NSLayoutConstraint*) stm_alignRightWithWidth:(CGFloat) width;
- (void) stm_alignToSuperview;

@end

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
@property (nonatomic,assign) CGFloat leftOpenPosition;
@property (nonatomic,assign) CGFloat leftClosedPosition;
@property (nonatomic,assign) CGFloat rightOpenPosition;
@property (nonatomic,assign) CGFloat rightClosedPosition;
@end

@implementation STMSideMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupShadowView];
    self.leftWidth = 200;
    self.rightWidth = 100;
    
    
}

- (void)setLeftWidth:(CGFloat)leftWidth {
    _leftWidth = leftWidth;
    self.leftOpenPosition = 0;
    self.leftClosedPosition = -leftWidth;
}
- (CGFloat)sideAnimationDuration {
    if(_sideAnimationDuration <= 0) {
        _sideAnimationDuration = 0.2;
    }
    return _sideAnimationDuration;
}
- (CGFloat)mainAnimationDuration {
    if (_mainAnimationDuration <= 0) {
        _mainAnimationDuration = 0.2;
    }
    return _mainAnimationDuration;
}
- (void)setRightWidth:(CGFloat)rightWidth {
    _rightWidth = rightWidth;
    self.rightOpenPosition  =  self.view.frame.size.width - rightWidth;
    self.rightClosedPosition  =  self.view.frame.size.width;
}
- (void) setupShadowView {
    UIView* shadowView = [[UIView alloc] init];
    self.shadowViewAlpha = 0.5;
    self.shadowViewColor = [UIColor blackColor];
    self.shadowView = shadowView;
    self.shadowView.backgroundColor = self.shadowViewColor;
    self.shadowView.alpha = self.shadowViewAlpha;
    [self.view addSubview:self.shadowView];
    self.shadowView.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideController:)];
    [self.shadowView addGestureRecognizer:tap];
    [self.shadowView stm_centerInSuperview];
}
- (void)setShadowViewColor:(UIColor *)shadowViewColor {
    _shadowViewColor = shadowViewColor;
    self.shadowView.backgroundColor = shadowViewColor;
}
- (void)setShadowViewAlpha:(CGFloat)shadowViewAlpha {
    _shadowViewAlpha = shadowViewAlpha;
    self.shadowView.alpha = shadowViewAlpha;
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
    BOOL isLeft = ((_panningView && _panningView == self.leftViewController.view) || (edge.edges == UIRectEdgeLeft)) ;
    
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
            self.leftConstraint.constant = x;
        }
        else {
            
            x =  MAX(openNW,MIN(x + self.panningPadding,closedNW));
            alpha   = self.shadowViewAlpha - ABS(self.shadowViewAlpha* (x - openNW)/(openNW-closedNW));
            NSLog(@"%.f",x);
            self.rightConstraint.constant = MAX(self.view.frame.size.width-self.rightClosedPosition,MIN(self.view.frame.size.width-self.rightOpenPosition,self.view.frame.size.width-x));
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
    [mainViewController.view stm_alignToSuperview];
    [self hideLeftViewControllerAnimated:animated];
    [self hideRightViewControllerAnimated:animated];
    void (^completion)(BOOL) = ^(BOOL finished) {
        [oldController.view removeFromSuperview];
        [oldController removeFromParentViewController];
    };
    if (animated) {
        [self animateFromView:oldController.view toView:mainViewController.view completion:completion];
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
    self.leftConstraint = [leftViewController.view stm_alignLeftWithWidth:w];
    [self hideLeftViewControllerAnimated:NO];
    leftViewController.view.userInteractionEnabled = YES;
    [leftViewController.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
    self.leftPanGesture.enabled = YES;
}

- (void) removeLeftViewController {
    
    [self hideLeftViewControllerAnimated:NO];
    self.leftPanGesture.enabled = NO;
    [self.leftViewController.view removeFromSuperview];
    [self.leftViewController removeFromParentViewController];
    _leftViewController = nil;
}
- (void) removeRightViewController {
    
    [self hideRightViewControllerAnimated:NO];
    self.rightPanGesture.enabled = NO;
    [self.rightViewController.view removeFromSuperview];
    [self.rightViewController removeFromParentViewController];
    _rightViewController = nil;
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
        [view.superview layoutIfNeeded];
        shadowView.alpha = shadowViewAlpha;
    };
    void (^completion)(BOOL) = ^(BOOL finished){
        
    };
    
    if (animated) {
        [UIView animateWithDuration:self.sideAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:animation completion:completion];
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
        [view.superview layoutIfNeeded];
        shadowView.alpha = 0;
    };
    void (^completion)(BOOL) = ^(BOOL finished){
        [view setNeedsUpdateConstraints];
        [view updateConstraintsIfNeeded];
        if (finished) shadowView.hidden = YES;
    };
    if (animated) {
        [UIView animateWithDuration:self.sideAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:animation completion:completion];
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
    self.rightConstraint = [rightViewController.view stm_alignRightWithWidth:self.rightWidth];
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
        [view.superview layoutIfNeeded];
        shadowView.alpha = shadowViewAlpha;
    };
    void (^completion)(BOOL) = ^(BOOL finished){
        ;
    };
    if (animated) {
        [UIView animateWithDuration:self.sideAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:animation completion:completion];
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
        [view.superview layoutIfNeeded];
        shadowView.alpha = 0;
    };
    void (^completion)(BOOL) = ^(BOOL finished){
        if (finished) shadowView.hidden = YES;
    };
    if (animated) {
        [UIView animateWithDuration:self.sideAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:animation completion:completion];
    }
    else {
        animation();
        completion(YES);
    }
}

#pragma mark Animations

- (void) animateFromView:(UIView*) fromView toView:(UIView*) toView completion:(void (^)(BOOL))completion {
    switch (self.animationType) {
        case STMAnimationCircularReveal:
            [self circularAnimationFromView:fromView toView:toView completion:completion];
            break;
        case STMAnimationSlideUp:
            [self slideUpAnimationFromView:fromView toView:toView completion:completion];
            break;
        case STMAnimationAlpha:
            [self alphaAnimationFromView:fromView toView:toView completion:completion];
            break;
        case STMAnimationCustom:
            [self customAnimationFromView:fromView toView:toView completion:completion];
            break;
        case STMAnimationNone:
        default:
            completion(NO);
            break;
    }
}
- (void) customAnimationFromView:(UIView*) fromView toView:(UIView*) toView completion:(void (^)(BOOL))completion {
    completion(YES);
}

- (void) alphaAnimationFromView:(UIView*) fromView toView:(UIView*) toView completion:(void (^)(BOOL))completion {
    toView.alpha = 0;
    [UIView animateWithDuration:self.mainAnimationDuration animations:^{
        toView.alpha = 1;
    } completion:completion];
    
}
- (CGRect) squareAroundPoint:(CGPoint) point withRadius:(CGFloat) radius {
    return CGRectInset(CGRectMake(point.x, point.y, 0, 0), -radius, -radius);
}

- (void) circularAnimationFromView:(UIView*) fromView toView:(UIView*) toView completion:(void (^)(BOOL))completion{
    CGFloat initialRadius = 20;
    CGFloat finalRadius = MAX(toView.frame.size.width,toView.frame.size.height)*2;
    UIBezierPath* start = [UIBezierPath bezierPathWithOvalInRect:[self squareAroundPoint:CGPointMake(0, 0) withRadius:initialRadius]];
    UIBezierPath* end = [UIBezierPath bezierPathWithOvalInRect:[self squareAroundPoint:CGPointMake(0,0) withRadius:finalRadius]];
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    mask.path = end.CGPath;
    [CATransaction begin];
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fromValue = (id)start.CGPath;
    animation.toValue = (id)end.CGPath;
    animation.duration = self.mainAnimationDuration;
    [CATransaction setCompletionBlock:^{
        completion(YES);
    }];
    toView.layer.mask = mask;
    [mask addAnimation:animation forKey:@"show"];
    [CATransaction commit];
    
}

- (void) slideUpAnimationFromView:(UIView*) fromView toView:(UIView*) toView completion:(void (^)(BOOL))completion{
    CGRect toViewEndFrame = toView.frame;
    CGRect toViewStartFrame = toView.frame;
    toViewStartFrame.origin.y = toViewStartFrame.origin.y + toViewStartFrame.size.height;
    CGRect fromViewEndFrame = fromView.frame;
    CGRect fromViewStartFrame = fromView.frame;
    fromViewEndFrame.origin.y = fromViewEndFrame.origin.y -  fromViewEndFrame.size.height;
    toView.frame = toViewStartFrame;
    fromView.frame = fromViewStartFrame;
    
    [UIView animateWithDuration:self.mainAnimationDuration animations:^{
        toView.frame = toViewEndFrame;
        fromView.frame = fromViewEndFrame;
    } completion:^(BOOL finished) {
        completion(YES);
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

- (NSLayoutConstraint*) stm_alignLeftWithWidth:(CGFloat) width {
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
- (NSLayoutConstraint*) stm_alignRightWithWidth:(CGFloat) width {
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

- (void) stm_alignToSuperview {
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
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:containerView
                                                              attribute:NSLayoutAttributeTrailing
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
    
    
    
    return ;
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
