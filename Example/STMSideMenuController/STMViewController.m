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
    UIViewController* mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"main"];

    
    [self performSegueWithIdentifier:@"leftMenuSegue" sender:nil];
    [self performSegueWithIdentifier:@"rightMenuSegue" sender:nil];
    self.mainViewController = mainViewController;
}
- (CGFloat)leftWidth {
    return 300;
}
- (CGFloat) rightWidth {
    return 176;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
