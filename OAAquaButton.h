// Copyright 2000-2005 Omni Development, Inc.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

@interface OAAquaButton : NSButton
{
    NSImage *clearImage;
    NSImage *aquaImage;
    NSImage *graphiteImage;
}

- (void)setImageName:(NSString *)anImageName inBundle:(NSBundle *)aBundle;
    // The image named anImageName will be used for the normal state of the button.  The alternate image of the button will be the image named anImageName with either "Aqua" or "Graphite" appended to it.    
@end

extern NSString *OAAquaButtonAquaImageSuffix;	// "Aqua"
extern NSString *OAAquaButtonGraphiteImageSuffix;	// "Graphite"

//
// Control tint utilities
//

typedef enum {
    OAUndefinedTint, OAAquaTint, OAGraphiteTint,
} OAControlTint;

extern OAControlTint OACurrentControlTint();
extern NSString *OAControlTintDidChangeNotification;