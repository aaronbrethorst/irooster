//
//  main.m
//  iRooster
//
//  Created by Aaron Brethorst on Mon Jun 30 2003.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

const char **tempArgv;

int main(int argc, const char *argv[])
{
    tempArgv = argv;
    return NSApplicationMain(argc, argv);
}
