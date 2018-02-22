//
//  File.m
//  Tovi
//
//  Created by ideawu on 13-3-25.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import "File.h"

@implementation File

+ (NSString *)trimpath:(NSString *)path{
	// FUCK!!!
	NSRange range = [path rangeOfString:@"file:///"];
	if(range.location == 0){
		range.length -= 1;
		path = [path stringByReplacingCharactersInRange:range withString:@""];
	}
	return path;
}

+ (bool)isdir:(NSString *)path{
	path = [self trimpath:path];
	NSError *err;
	NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&err];
	NSString *type = [attr objectForKey:NSFileType];
	if(type && [type compare:NSFileTypeDirectory] == NSOrderedSame){
		return true;
	}
	return false;
}

+ (bool)isfile:(NSString *)path{
	path = [self trimpath:path];
	NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
	NSString *type = [attr objectForKey:NSFileType];
	if([type compare:NSFileTypeRegular] == NSOrderedSame){
		return true;
	}
	return false;
}

+ (NSString *)fullpath:(NSString *)path{
	path = [self trimpath:path];
	NSURL *url = [NSURL fileURLWithPath:path];
	return url.path;
}

+ (NSString *)extension:(NSString *)path{
	path = [self trimpath:path];
	return [path pathExtension];
}

+ (NSString *)basename:(NSString *)path{
	path = [self trimpath:path];
	return [path lastPathComponent];
}

+ (NSString *)dirname:(NSString *)path{
	path = [self trimpath:path];
	return [path stringByDeletingLastPathComponent];
}

+ (NSArray *)scandir:(NSString *)dir{
	dir = [self trimpath:dir];
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
	return files;
}

+ (NSArray *)scandir:(NSString *)dir fullpath:(BOOL)fullpath{
	dir = [self trimpath:dir];
	NSMutableArray *ret = [NSMutableArray array];
	for(NSString *f in [self scandir:dir]){
		if(fullpath){
			NSString *s = [NSString stringWithFormat:@"%@/%@", dir, f, nil];
			[ret addObject:s];
		}else{
			[ret addObject:f];
		}
	}
	return [ret sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
}


+ (NSArray *)glob:(NSString *)dir{
	dir = [self trimpath:dir];
	return nil;
}

@end
