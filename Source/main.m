/***************************************************************************
 *   Copyright (C) 2009-2010 by Clockwise   *
 *   copyright@clockwise.ee   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#import "Network.h"
#import "PrivilegedActions.h"
#include <pthread.h>

BOOL _openedAtLogin = NO;
BOOL _reopened = NO;

BOOL openedAtLogin()
{
	return _openedAtLogin;
}

BOOL reopened()
{
	return _reopened;
}

void* PosixThreadMainRoutine(void* data)
{
    while(1) {
        [PrivilegedActions updateDNS];
        sleep(50);
    }
    return NULL;
}


int main(int argc, char *argv[])
{	
	@autoreleasepool {
        [Logger setup];
	
        logDebug(@"Starting Gas Mask %@", [NSApplication version]);

        [[Network defaultInstance] startListeningForChanges];
	
        for (int i=0; i<argc; i++) {
            if (strcmp(argv[i], "openatlogin") == 0) {
                _openedAtLogin = YES;
                logDebug(@"Opened At Login");
            }
            else if (strcmp(argv[i], "#reopen#") == 0) {
                _reopened = YES;
                logDebug(@"Reopen");
            }
        }
	}
    
    pthread_attr_t  attr;
    pthread_t       posixThreadID;
    int             returnVal;
    
    returnVal = pthread_attr_init(&attr);
    assert(!returnVal);
    returnVal = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    assert(!returnVal);
    
    int     threadError = pthread_create(&posixThreadID, &attr, &PosixThreadMainRoutine, NULL);
    
    returnVal = pthread_attr_destroy(&attr);
    assert(!returnVal);
    if (threadError != 0)
    {
        // Report an error.
    }
    
	
    return NSApplicationMain(argc,  (const char **) argv);
}
