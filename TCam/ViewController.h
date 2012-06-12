//
//  ViewController.h
//  TCam
//
//  Created by Mohammad Azam on 5/27/12.
//  Copyright (c) 2012 HighOnCoding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    CIContext *context; 
    NSMutableArray *filters; 
    CIImage *beginImage; 
}

@property (nonatomic,weak) IBOutlet UIScrollView *filtersScrollView; 
@property (nonatomic,weak) IBOutlet UIImageView *imageView; 


@end
