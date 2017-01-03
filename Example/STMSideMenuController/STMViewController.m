//
//  STMViewController.m
//  STMSideMenuController
//
//  Created by Stefano Mondino on 06/09/2015.
//  Copyright (c) 2014 Stefano Mondino. All rights reserved.
//

#import "STMViewController.h"

@interface STMViewController ()

@end

@implementation STMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.leftWidth = 250;
    self.rightWidth = 150;
    self.leftParallaxAmount = 0.5;
    self.rightParallaxAmount = 0.2;
    self.animationType = STMAnimationSlideUp;
    
    UIViewController* mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"main"];

    
    [self performSegueWithIdentifier:@"leftMenuSegue" sender:nil];
   // [self performSegueWithIdentifier:@"rightMenuSegue" sender:nil];
    self.mainViewController = mainViewController;
}
/*
- (CGFloat)leftWidth {
    return 300;
}
- (CGFloat) rightWidth {
    return 176;
}
*/
@end
