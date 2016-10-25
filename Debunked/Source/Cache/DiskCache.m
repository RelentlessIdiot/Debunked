//  Created by David Golightly on 2/16/09.
//  Copyright 2009 David Golightly. All rights reserved.
//
//
//  Modifications Copyright (c) 2009-2016 Robert Ruana <rob@robruana.com>
//
//  This file is part of Debunked.
//
//  Debunked is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Debunked is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Debunked.  If not, see <http://www.gnu.org/licenses/>.

#import "DiskCache.h"

static DiskCache *sharedInstance;

@interface DiskCache (Privates)

- (void)trimDiskCacheFilesToMaxSize:(NSUInteger)targetBytes;

@end


@implementation DiskCache
@dynamic sizeOfCache, cacheDir;


- (id)init {
	
	if (self = [super init]) {
		[self trimDiskCacheFilesToMaxSize:kMaxDiskCacheSize];
	}
	return self;
	
}


- (NSString *)cacheDir {
	
	if (_cacheDir == nil) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		_cacheDir = [[NSString alloc] initWithString:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"URLCache"]];
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:_cacheDir]) {
		return _cacheDir;
	}
	
	if (![[NSFileManager defaultManager] createDirectoryAtPath:_cacheDir withIntermediateDirectories:NO attributes:nil error:nil]) {
		NSLog(@"Error creating cache directory");
	}
	return _cacheDir;
	
}


- (NSString *)localPathForURL:(NSURL *)url
{
	NSString *filename = [[[url path] componentsSeparatedByString:@"/"] lastObject];
	NSString *path = [[url path] substringToIndex:[[url path] length] - ([filename length] + 1)];
	NSString *cache = [[self cacheDir] stringByAppendingPathComponent:path];
	if (![[NSFileManager defaultManager] fileExistsAtPath:cache]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:cache withIntermediateDirectories:YES attributes:nil error:nil];
	}
	NSString *query = [url query];
	if (query != nil) {
		filename = [filename stringByAppendingString:@"__"];
		filename = [filename stringByAppendingString:query];
		filename = [filename stringByReplacingOccurrencesOfString:@"&" withString:@"__"];
		filename = [filename stringByReplacingOccurrencesOfString:@"=" withString:@"__"];
		filename = [filename stringByReplacingOccurrencesOfString:@"+" withString:@"__"];
	}
	return [cache stringByAppendingPathComponent:filename];
	
}


- (NSData *)imageDataInCacheForURLString:(NSString *)urlString {
	NSString *localPath = [self localPathForURL:[NSURL URLWithString:urlString]];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
		// "touch" the file so we know when it was last used
		[[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil] 
										 ofItemAtPath:localPath 
												error:nil];
		return [[NSFileManager defaultManager] contentsAtPath:localPath];
	}
	
	return nil;
}


- (NSData *)dataInCacheForURLString:(NSString *)urlString
{
	return [self dataInCacheForURLString:urlString withExpiration:-1];
}
	
	
- (NSData *)dataInCacheForURLString:(NSString *)urlString withExpiration:(NSInteger) expiration
{
	NSString *localPath = [self localPathForURL:[NSURL URLWithString:urlString]];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		NSError *e = nil;
		NSDictionary *attributes = [fileManager attributesOfItemAtPath:localPath error:&e];
		NSDate *created = [attributes objectForKey:NSFileModificationDate];
		NSDate *now = [NSDate date];
		if (expiration == 0 || (expiration != -1 && [now timeIntervalSinceDate:created] > expiration)) {
			[fileManager removeItemAtPath:localPath error:&e];
			return nil;
		} else {
			return [fileManager contentsAtPath:localPath];
		}
	}
	
	return nil;
}


- (void)cacheData:(NSData *)data   
		  request:(NSWebViewURLRequest *)request
		 response:(NSURLResponse *)response {
	
	if (request != nil && 
		response != nil && 
		data != nil &&
		[data length] > 0) {
		NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response 
                                                                                       data:data];
		[[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse 
											  forRequest:request];
		
		if ([self sizeOfCache] >= kMaxDiskCacheSize) {
			[self trimDiskCacheFilesToMaxSize:kMaxDiskCacheSize * 0.75];
		}
		
		NSString *localPath = [self localPathForURL:[request URL]];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if ( [fileManager fileExistsAtPath:localPath] == NO ) {
			if ( [fileManager createFileAtPath:localPath contents:data attributes:nil] == NO ) {
				NSLog(@"  ERROR: Could not create file at path: %@", localPath);
			} else {
				_cacheSize += [data length];
				
				[fileManager setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil] 
							  ofItemAtPath:localPath 
									 error:nil];	
			}
		}
		
        [cachedResponse release];
	}
	
}


- (void)cacheImageData:(NSData *)imageData   
			   request:(NSWebViewURLRequest *)request
			  response:(NSURLResponse *)response {
	
	if (request != nil && 
		response != nil && 
		imageData != nil &&
		[imageData length] > 0) {
		NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response 
                                                                                       data:imageData];
		[[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse 
											  forRequest:request];
		
		if ([self sizeOfCache] >= kMaxDiskCacheSize) {
			[self trimDiskCacheFilesToMaxSize:kMaxDiskCacheSize * 0.75];
		}
		
		NSString *localPath = [self localPathForURL:[request URL]];
		if ( [[NSFileManager defaultManager] fileExistsAtPath:localPath] == NO ) {
			if ( [[NSFileManager defaultManager] createFileAtPath:localPath contents:imageData attributes:nil] == NO ) {
				NSLog(@"  ERROR: Could not create file at path: %@", localPath);
			} else {
				_cacheSize += [imageData length];	
			}
		}
		
        [cachedResponse release];
	}
	
}


- (void)clearCachedDataForRequest:(NSWebViewURLRequest *)request {
	
	[[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
	NSData *data = [self imageDataInCacheForURLString:[[request URL] path]];
	_cacheSize -= [data length];
	[[NSFileManager defaultManager] removeItemAtPath:[self localPathForURL:[request URL]] 
											   error:nil];
	
}


- (NSUInteger)sizeOfCache {
	
	NSString *cacheDir = [self cacheDir];
	if (_cacheSize <= 0 && cacheDir != nil) {
		NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cacheDir error:nil];
		NSString *file;
		NSDictionary *attrs;
		NSNumber *fileSize;
		NSUInteger totalSize = 0;
		
		for (file in dirContents) {
			attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[cacheDir stringByAppendingPathComponent:file] error:nil];
			fileSize = [attrs objectForKey:NSFileSize];
			totalSize += [fileSize integerValue];
		}
		
		_cacheSize = totalSize;
	}
	return _cacheSize;
	
}


NSInteger dateModifiedSort(id file1, id file2, void *reverse) {
	
	NSDictionary *attrs1 = [[NSFileManager defaultManager] attributesOfItemAtPath:file1 error:nil];
	NSDictionary *attrs2 = [[NSFileManager defaultManager] attributesOfItemAtPath:file2 error:nil];
	
	if ((NSInteger *)reverse == NO) {
		return [[attrs2 objectForKey:NSFileModificationDate] compare:[attrs1 objectForKey:NSFileModificationDate]];
	}
	
	return [[attrs1 objectForKey:NSFileModificationDate] compare:[attrs2 objectForKey:NSFileModificationDate]];
	
}


- (void)trimDiskCacheFilesToMaxSize:(NSUInteger)targetBytes {
	
	targetBytes = MIN(kMaxDiskCacheSize, MAX(0, targetBytes));
	if ([self sizeOfCache] > targetBytes) {
		NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self cacheDir] error:nil];
		
		NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
		for (NSString *file in dirContents) {
			NSString *pathExt = [file pathExtension];
			if ( [pathExt isEqualToString:@"jpg"] || [pathExt isEqualToString:@"png"] ) {
				[filteredArray addObject:[[self cacheDir] stringByAppendingPathComponent:file]];
			}
		}
		
		int reverse = YES;
		NSMutableArray *sortedDirContents = [NSMutableArray arrayWithArray:[filteredArray sortedArrayUsingFunction:dateModifiedSort context:&reverse]];
		while (_cacheSize > targetBytes && [sortedDirContents count] > 0) {
			_cacheSize -= [[[[NSFileManager defaultManager] attributesOfItemAtPath:[sortedDirContents lastObject] error:nil] objectForKey:NSFileSize] integerValue];
			[[NSFileManager defaultManager] removeItemAtPath:[sortedDirContents lastObject] error:nil];

			[sortedDirContents removeLastObject];
		}
        [filteredArray release];
	}
	
}

#pragma mark
#pragma mark ---- singleton implementation ----

+ (DiskCache *)sharedCache {
	
    @synchronized (sharedInstance) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
	
}


+ (id)allocWithZone:(NSZone *)zone {
	
    @synchronized (sharedInstance) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
	
}


@end
