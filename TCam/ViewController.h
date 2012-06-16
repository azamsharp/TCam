//
//  ViewController.h
//  TCam
//
//  Created by Mohammad Azam on 5/27/12.
//  Copyright (c) 2012 HighOnCoding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>

@interface ViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    CIContext *context; 
    NSMutableArray *filters; 
    CIImage *beginImage; 
    UIScrollView *filtersScrollView; 
    UIView *selectedFilterView; 
    UIImage *finalImage;
    
}

-(IBAction) tweetButtonTouched:(id) sender; 

@property (nonatomic,weak) IBOutlet UIImageView *imageView; 
@property (nonatomic,weak) IBOutlet UIToolbar *toolbar;

@end
