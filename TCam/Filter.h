//
//  Filter.h
//  TCam
//
//  Created by Mohammad Azam on 6/7/12.
//  Copyright (c) 2012 HighOnCoding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Filter : NSObject
{
    
}

-(id) initWithNameAndFilter:(NSString *) theName filter:(CIFilter *) theFilter; 

@property (nonatomic,strong) NSString *name; 
@property (nonatomic,strong) CIFilter *filter; 

@end
