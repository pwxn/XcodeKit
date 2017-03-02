//
//  SourceEditorCommand.m
//  XcodeKit8
//
//  Created by Paul Landers on 2/2/17.
//  Copyright © 2017 Plamen Todorov. All rights reserved.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    
    NSMutableArray<XCSourceTextRange *> *selectedRanges =  invocation.buffer.selections;
    NSMutableArray<NSString*> *lines = invocation.buffer.lines;
    
    if ([invocation.commandIdentifier isEqualToString:@"com.pwxn.XcodeKit8App.XcodeKit8.DeleteLine"]){
        // Delete all lines that are selected with the first selection
        if(selectedRanges.count && selectedRanges.firstObject.start.line != selectedRanges.firstObject.end.line ){
            [lines removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(selectedRanges.firstObject.start.line, selectedRanges.firstObject.end.line - selectedRanges.firstObject.start.line)]];
        }
        else {
            NSInteger firstSelectionLine =  selectedRanges.firstObject.start.line;
            [lines removeObjectAtIndex:firstSelectionLine];
            if (firstSelectionLine != 0){
                [selectedRanges removeAllObjects];
                [selectedRanges addObject:[[XCSourceTextRange alloc] initWithStart:XCSourceTextPositionMake(firstSelectionLine, lines[firstSelectionLine].length-1)
                                                                               end:XCSourceTextPositionMake(firstSelectionLine, lines[firstSelectionLine].length-1)]];
            }
        }
    } else if ([invocation.commandIdentifier isEqualToString:@"com.pwxn.XcodeKit8App.XcodeKit8.DuplicateLine"]){
        NSInteger firstSelectionLine =  selectedRanges.firstObject.start.line;
        if (firstSelectionLine >= invocation.buffer.lines.count){
            completionHandler([NSError errorWithDomain:@"Can't duplicate a line without an ending." code:0 userInfo:nil]);
            return;
        }
        [lines insertObject:lines[firstSelectionLine] atIndex:firstSelectionLine+1];
        
        [selectedRanges removeAllObjects];
        [selectedRanges addObject:[[XCSourceTextRange alloc] initWithStart:XCSourceTextPositionMake(firstSelectionLine, lines[firstSelectionLine].length-1)
                                                                       end:XCSourceTextPositionMake(firstSelectionLine, lines[firstSelectionLine].length-1)]];
    } else if ([invocation.commandIdentifier isEqualToString:@"com.pwxn.XcodeKit8App.XcodeKit8.NewLineAfterCurrent"]){
        NSInteger firstSelectionLine =  selectedRanges.firstObject.start.line;
        NSString * previous = lines[firstSelectionLine];
        NSInteger charLoc = [previous rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]].location;
        previous = charLoc == NSNotFound ? @"\n" : [[previous substringToIndex:charLoc] stringByAppendingString:@"\n"];
        [lines insertObject:previous atIndex:firstSelectionLine+1];
        
        [selectedRanges removeAllObjects];
        [selectedRanges addObject:[[XCSourceTextRange alloc] initWithStart:XCSourceTextPositionMake(firstSelectionLine+1, lines[firstSelectionLine+1].length-1)
                                                                       end:XCSourceTextPositionMake(firstSelectionLine+1, lines[firstSelectionLine+1].length-1)]];
        
    } else if ([invocation.commandIdentifier isEqualToString:@"com.pwxn.XcodeKit8App.XcodeKit8.CRLFtoLF"]){
        for (NSInteger i = selectedRanges.firstObject.start.line; i <= selectedRanges.firstObject.end.line; i++){
            if ([lines[i] hasSuffix:@"\r\n"])
                lines[i] = [lines[i] stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
        }
    }
    
    completionHandler(nil);
}

@end
