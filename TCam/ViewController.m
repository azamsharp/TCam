//
//  ViewController.m
//  TCam
//
//  Created by Mohammad Azam on 5/27/12.
//  Copyright (c) 2012 HighOnCoding. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Filter.h" 
#import "UIImage+Extensions.h" 

@implementation ViewController

static inline double radians (double degrees) {return degrees * M_PI/180;}

@synthesize imageView,filtersScrollView; 

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    
    [self setup];    
}

-(void) setup 
{
    [self setupAppearance];
    [self initializeFilterContext];
    //[self loadFilters];
    
}

-(void) initializeFilterContext 
{
    context = [CIContext contextWithOptions:nil];
 
}

-(void) setupAppearance 
{
    [self.filtersScrollView setScrollEnabled:YES];
    [self.filtersScrollView setShowsVerticalScrollIndicator:NO];

    UIBarButtonItem *cameraBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
    
    [[self navigationItem] setRightBarButtonItem:cameraBarButtonItem];
    
}

-(void) applyGesturesToFilterPreviewImageView:(UIView *) view 
{
    NSLog(@"applyGesturesToFilterPreviewImageView");
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(applyFilter:)];

    singleTapGestureRecognizer.numberOfTapsRequired = 1; 

    [view addGestureRecognizer:singleTapGestureRecognizer];        
}

-(void) applyFilter:(id) sender 
{
    NSLog(@"applyFilter");
    
        int filterIndex = [(UITapGestureRecognizer *) sender view].tag;
        Filter *filter = [filters objectAtIndex:filterIndex];
    
        CIImage *outputImage = [filter.filter outputImage];
        
        CGImageRef cgimg = 
        [context createCGImage:outputImage fromRect:[outputImage extent]];
        
        UIImage *finalImage = [UIImage imageWithCGImage:cgimg];
        
        finalImage = [finalImage imageRotatedByDegrees:90];  
    
        [self.imageView setImage:finalImage];
    
        CGImageRelease(cgimg);
    
}

-(void) createPreviewViewsForFilters
{
    int offsetX = 0; 

    for(int index = 0; index < [filters count]; index++)
    {
        UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(offsetX, 0, 60, 60)];
        
        // create a label to display the name 
        UILabel *filterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, filterView.bounds.size.width, 8)];
        
        filterNameLabel.center = CGPointMake(filterView.bounds.size.width/2, filterView.bounds.size.height + filterNameLabel.bounds.size.height); 
        
        Filter *filter = (Filter *) [filters objectAtIndex:index];
        
        filterNameLabel.text =  filter.name;
        filterNameLabel.backgroundColor = [UIColor clearColor];
        filterNameLabel.textColor = [UIColor whiteColor];
        filterNameLabel.font = [UIFont fontWithName:@"AppleColorEmoji" size:10];
        filterNameLabel.textAlignment = UITextAlignmentCenter;

        CIImage *outputImage = [filter.filter outputImage];
        
        CGImageRef cgimg = 
        [context createCGImage:outputImage fromRect:[outputImage extent]];

        UIImage *smallImage =  [UIImage imageWithCGImage:cgimg];
        
        if(smallImage.imageOrientation == UIImageOrientationUp) 
        {
            smallImage = [smallImage imageRotatedByDegrees:90];
        }

        // create filter preview image views 
        UIImageView *filterPreviewImageView = [[UIImageView alloc] initWithImage:smallImage];
        
        [filterView setUserInteractionEnabled:YES];
        
        filterPreviewImageView.layer.cornerRadius = 10;  
        filterPreviewImageView.opaque = NO;
        filterPreviewImageView.backgroundColor = [UIColor clearColor];
        filterPreviewImageView.layer.masksToBounds = YES;        
        filterPreviewImageView.frame = CGRectMake(0, 0, 60, 60); 
        
        filterView.tag = index; 

        [self applyGesturesToFilterPreviewImageView:filterView];
        
        [filterView addSubview:filterPreviewImageView];
        [filterView addSubview:filterNameLabel];
        
        [self.filtersScrollView addSubview:filterView];
        
        offsetX += filterView.bounds.size.width + 10;
        
    }
    
     [self.filtersScrollView setContentSize:CGSizeMake(400, 60)]; 
}

-(void) loadFiltersForImage:(UIImage *) image
{
 
    CIImage *filterPreviewImage = [[CIImage alloc] initWithImage:image]; 
    
    CIFilter *sepiaFilter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey,filterPreviewImage,
                             @"inputIntensity",[NSNumber numberWithFloat:0.8],nil];
        
    
    CIFilter *colorMonochrome = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:kCIInputImageKey,filterPreviewImage,
                                @"inputColor",[CIColor colorWithString:@"Red"],
                                 @"inputIntensity",[NSNumber numberWithFloat:0.8], nil];
    
    filters = [[NSMutableArray alloc] init];
    

    [filters addObjectsFromArray:[NSArray arrayWithObjects:
                                  [[Filter alloc] initWithNameAndFilter:@"Sepia" filter:sepiaFilter],
                                  [[Filter alloc] initWithNameAndFilter:@"Mono" filter:colorMonochrome]
                
                                  , nil]];
    
    
    [self createPreviewViewsForFilters];
}

-(void) takePicture:(id) sender 
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) 
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else 
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [imagePicker setDelegate:self];
    
    [self presentModalViewController:imagePicker animated:YES];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if(image.imageOrientation == UIImageOrientationUp) 
    {
        NSLog(@"Portrait");
    }
    else if(image.imageOrientation == UIImageOrientationDown) 
    {
         NSLog(@"Down");
    }
    else if(image.imageOrientation == UIImageOrientationRight) 
    {
         NSLog(@"didFinishPickingMediaWithInfo: Right");
    }
    else if(image.imageOrientation == UIImageOrientationLeft) 
    {
         NSLog(@"Left");
    }
        
    // rotate the image 
    
   // [self rotate:image];
    
    [self.imageView setImage:image];
    
   // UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    
    [self dismissModalViewControllerAnimated:YES];
    
    // load the filters again 
    
    [self loadFiltersForImage:image];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
