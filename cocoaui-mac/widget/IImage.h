/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IView.h"

@interface IImage : IView

@property (nonatomic) NSImageView *imageView;

@property (nonatomic) NSString *src;
@property (nonatomic) NSImage *image;

+ (IImage *)imageNamed:(NSString *)name;

@end
