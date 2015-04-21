//
//  BridgingHelpers.m
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/6/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

#import "BridgingHelpers.h"

#include <asl.h>

int my_asl_log_message(int level, const char *string) {
    return asl_log_message(level, "%s", string);
}
