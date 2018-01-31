//
//  TestWindow.m
//  Test
//
//  Created by ideawu on 30/01/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#import "TestWindow.h"
#import "IView.h"
#import "ILabel.h"

@interface TestWindow ()<NSWindowDelegate>

@end

@implementation TestWindow

- (id)init{
	self = [super initWithWindowNibName:@"TestWindow"];
	self.window.delegate = self;
	return self;
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	IView *view = [IView namedView:@"Test"];
	[self.window.contentView addSubview:view];
}

@end
