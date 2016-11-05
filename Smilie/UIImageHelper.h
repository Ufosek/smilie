//
//  UIImageHelper.h
//  Smilie
//
//  Created by Ufos on 01.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

#ifndef UIImageHelper_h
#define UIImageHelper_h


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface UIImageHelper : NSObject

+ (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;

@end


#endif /* UIImageHelper_h */
