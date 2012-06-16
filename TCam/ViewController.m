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

static const int FILTER_LABEL = 001; 
    

@synthesize imageView; 

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
    [self loadFiltersForImage:[UIImage imageNamed:@"biscus_small.png"]];
    
}

-(void) initializeFilterContext 
{
    context = [CIContext contextWithOptions:nil];
}

-(void) setupAppearance 
{
    filtersScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 300, self.view.bounds.size.width, 90)];

    [filtersScrollView setScrollEnabled:YES];
    [filtersScrollView setShowsVerticalScrollIndicator:NO];
    filtersScrollView.showsHorizontalScrollIndicator = NO; 

    UIBarButtonItem *cameraBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
    
    [[self navigationItem] setRightBarButtonItem:cameraBarButtonItem];
    
    [self.view addSubview:filtersScrollView];    
    
}

-(void) applyGesturesToFilterPreviewImageView:(UIView *) view 
{
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(applyFilter:)];

    singleTapGestureRecognizer.numberOfTapsRequired = 1; 

    [view addGestureRecognizer:singleTapGestureRecognizer];        
}


-(void) applyFilter:(id) sender 
{
    
        selectedFilterView.layer.shadowRadius = 0.0f; 
        selectedFilterView.layer.shadowOpacity = 0.0f;
    
        selectedFilterView = [(UITapGestureRecognizer *) sender view];
    
        selectedFilterView.layer.shadowColor = [UIColor yellowColor].CGColor;
        selectedFilterView.layer.shadowRadius = 3.0f; 
        selectedFilterView.layer.shadowOpacity = 0.9f;
        selectedFilterView.layer.shadowOffset = CGSizeZero;
        selectedFilterView.layer.masksToBounds = NO;
    
        int filterIndex = selectedFilterView.tag; 
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
    int offsetX = 10; 

    for(int index = 0; index < [filters count]; index++)
    {
        UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(offsetX, 0, 60, 60)];
        
        
        filterView.tag = index; 
        
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
        
        filterPreviewImageView.layer.cornerRadius = 15;  
        filterPreviewImageView.opaque = NO;
        filterPreviewImageView.backgroundColor = [UIColor clearColor];
        filterPreviewImageView.layer.masksToBounds = YES;        
        filterPreviewImageView.frame = CGRectMake(0, 0, 60, 60); 
        
        filterView.tag = index; 

        [self applyGesturesToFilterPreviewImageView:filterView];
        
        [filterView addSubview:filterPreviewImageView];
        [filterView addSubview:filterNameLabel];
        
        [filtersScrollView addSubview:filterView];
        
        offsetX += filterView.bounds.size.width + 10;
        
    }
    
     [filtersScrollView setContentSize:CGSizeMake(400, 90)]; 
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
