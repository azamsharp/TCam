//
//  Filter.m
//  TCam
//
//  Created by Mohammad Azam on 6/7/12.
//  Copyright (c) 2012 HighOnCoding. All rights reserved.
//

#import "Filter.h"

@implementation Filter

@synthesize name, filter; 

-(id) initWithNameAndFilter:(NSString *)theName filter:(CIFilter *)theFilter
{
    self = [super init]; 
    
    self.name = theName; 
    self.filter = theFilter; 
    
    return self; 
}

@end
