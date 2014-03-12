//
//  UIImagePickerController+StatusBarHidden.m
//  Tap That
//
//  Created by Allan Zhang on 1/27/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "UIImagePickerController+StatusBarHidden.h"

@implementation UIImagePickerController (StatusBarHidden)

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(UIViewController *) childViewControllerForStatusBarHidden {
    return nil;
}

@end
