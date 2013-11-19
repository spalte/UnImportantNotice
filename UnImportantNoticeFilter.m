/*  UnImportantNotice

 Copyright (c) 2013, Spaltenstein Natural Image
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of Spaltenstein Natural Image nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL SPALTENSTEIN NATURAL IMAGE BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.*/

#import <objc/runtime.h>

#import <Foundation/Foundation.h>

@class ViewerController;
@interface PluginFilter : NSObject
{
	ViewerController*   viewerController;
}
@end

@interface UnImportantNoticeFilter : PluginFilter
@end

@implementation UnImportantNoticeFilter

- (void) initPlugin
{
	Class AppControllerClass = objc_getClass("AppController");
	if (AppControllerClass == nil)
	{
		NSLog(@"UnImportantNoticeFilter could not find the AppControllerClass");
		return;
	}
	
	Class BrowserControllerClass = objc_getClass("BrowserController");
	if (BrowserControllerClass == nil)
	{
		NSLog(@"UnImportantNoticeFilter could not find the BrowserControllerClass");
		return;
	}
	
    // get rid of the dialog when the window opens
	Method importantMethod = class_getClassMethod(AppControllerClass, @selector(displayImportantNotice:));
	Method unImportantMethod = class_getClassMethod([UnImportantNoticeFilter class], @selector(displayUnImportantNotice:));
	if (importantMethod == NULL || unImportantMethod == NULL)
	{
		NSLog(@"UnImportantNoticeFilter could not find the important methods");
		return;
	}
	
	IMP unImportantImp = method_getImplementation(unImportantMethod);
	if (unImportantImp == NULL)
	{
		NSLog(@"UnImportantNoticeFilter could not find the unImportantImp");
		return;
	}
	
	method_setImplementation(importantMethod, unImportantImp);
    
    // get rid of the message in the DCMView
    Method isFDAClearedMethod = class_getClassMethod(AppControllerClass, @selector(isFDACleared));
	Method unImportantIsFDAClearedMethod = class_getClassMethod([UnImportantNoticeFilter class], @selector(isFDAClearedUnImportantNotice));
	if (isFDAClearedMethod == NULL || unImportantIsFDAClearedMethod == NULL)
	{
		NSLog(@"UnImportantNoticeFilter could not find the isFDACleared methods");
		return;
	}
    
    IMP isFDAClearedUnImportantNoticeImp = method_getImplementation(unImportantIsFDAClearedMethod);
	if (isFDAClearedUnImportantNoticeImp == NULL)
	{
		NSLog(@"UnImportantNoticeFilter could not find the isFDAClearedUnImportantNoticeImp");
		return;
	}
    
    const char* isFDAClearedUnImportantNoticeTypes = method_getTypeEncoding(isFDAClearedMethod);
    if (isFDAClearedUnImportantNoticeTypes) {
        if (class_addMethod(object_getClass(AppControllerClass), @selector(isFDAClearedUnImportantNotice), isFDAClearedUnImportantNoticeImp, isFDAClearedUnImportantNoticeTypes)) {
            Method unImportantIsFDAClearedMethodAppController = class_getClassMethod(AppControllerClass, @selector(isFDAClearedUnImportantNotice));
            method_exchangeImplementations(isFDAClearedMethod, unImportantIsFDAClearedMethodAppController);
        }
    }
    
    // get rid of the banner
    Method checkForBannerMethod = class_getInstanceMethod(BrowserControllerClass, @selector(checkForBanner:));
	Method checkForUnImportantBannerMethod = class_getInstanceMethod([UnImportantNoticeFilter class], @selector(checkForUnImportantBanner:));
	if (checkForBannerMethod == NULL || checkForUnImportantBannerMethod == NULL)
	{
		NSLog(@"UnImportantNoticeFilter could not find the important banner methods");
		return;
	}
	
	IMP checkForUnImportantBannerImp = method_getImplementation(checkForUnImportantBannerMethod);
	if (checkForUnImportantBannerImp == NULL)
	{
		NSLog(@"UnImportantNoticeFilter could not find the checkForUnImportantBannerImp");
		return;
	}
	
	method_setImplementation(checkForBannerMethod, checkForUnImportantBannerImp);
}

+ (void)displayUnImportantNotice:(id)sender
{
	NSLog(@"UnImportantNoticeFilter: short-circuited +[AppController displayImportantNotice:]");
}

+ (BOOL)isFDAClearedUnImportantNotice
{
    NSArray *symbols = [NSThread callStackSymbols];
    if ([symbols count] >=2) {
        NSString *secondFrame = [symbols objectAtIndex:1];
        if ([secondFrame rangeOfString:@"drawTextualData:annotationsLevel:fullText:onlyOrientation:"].location != NSNotFound) {
            static BOOL printedLog = NO;
            if (printedLog == NO) {
                NSLog(@"UnImportantNoticeFilter: short-circuited +[AppController isFDACleared] because it was called from -[DCMView drawTextualData:annotationsLevel:fullText:onlyOrientation:] (this message is printed only once)");
            }
            printedLog = YES;
            return YES;
        }
    }
    return [self  isFDAClearedUnImportantNotice];
}

- (void)checkForUnImportantBanner:(id)sender
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSImage *bannerImage = [[[NSImage alloc] init] autorelease];
    if( bannerImage) {
        [self performSelectorOnMainThread: @selector(installBanner:) withObject:bannerImage waitUntilDone:NO modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    }
    [pool release];
    NSLog(@"UnImportantNoticeFilter: short-circuited -[BrowserController checkForBanner:]");
}


@end

