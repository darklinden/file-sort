//
//  main.m
//  file-sort
//
//  Created by HanShaokun on 21/8/15.
//  Copyright (c) 2015 by. All rights reserved.
//

#import <Foundation/Foundation.h>

//void enumFolder(NSString *folderPath)
//{
//    printf("enum folder: %s", folderPath.UTF8String);
//    NSFileManager *fmgr = [NSFileManager defaultManager];
//    NSError *err = nil;
//    NSArray *array = [fmgr contentsOfDirectoryAtPath:folderPath error:&err];
//    if (err) {
//        printf("error with enum folder: %s err: %s \n", folderPath.UTF8String, err.description.UTF8String);
//    }
//    else {
//        for (NSString *name in array) {
//            NSString *path = [folderPath stringByAppendingPathComponent:name];
//            BOOL isDirectory = NO;
//            [fmgr fileExistsAtPath:path isDirectory:&isDirectory];
//            
//            switch (op) {
//                case OperationDecrypt:
//                {
//                    if (isDirectory) {
//                        enumFolder(path, op);
//                    }
//                    else {
//                        
//                        NSString *extension = path.pathExtension.lowercaseString;
//                        if (![extension isEqualToString:@"png"]
//                            && ![extension isEqualToString:@"jpg"]
//                            && ![extension isEqualToString:@"jpeg"]) {
//                            continue;
//                        }
//                        
//                        int try = 0;
//                        while (!isImageReadable(path)) {
//                            try++;
//                            DecryptFile(path);
//                            
//                            if (try >= 3) {
//                                break;
//                            }
//                        }
//                        
//                        while (!isImageReadable(path)) {
//                            try++;
//                            EncryptFile(path);
//                            
//                            if (try >= 6) {
//                                break;
//                            }
//                        }
//                        
//                        if (!isImageReadable(path)) {
//                            NSString* msg = [NSString stringWithFormat:@"%@ 解密失败！", path.lastPathComponent];
//                            [[NSAlert alertWithMessageText:msg defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil] runModal];
//                        }
//                    }
//                }
//                    break;
//                case OperationEncrypt:
//                {
//                    if (isDirectory) {
//                        enumFolder(path, op);
//                    }
//                    else {
//                        
//                        NSString *extension = path.pathExtension.lowercaseString;
//                        if (![extension isEqualToString:@"png"]
//                            && ![extension isEqualToString:@"jpg"]
//                            && ![extension isEqualToString:@"jpeg"]) {
//                            continue;
//                        }
//                        
//                        int try = 0;
//                        while (!isImageReadable(path)) {
//                            try++;
//                            DecryptFile(path);
//                            
//                            if (try >= 3) {
//                                break;
//                            }
//                        }
//                        
//                        while (!isImageReadable(path)) {
//                            try++;
//                            EncryptFile(path);
//                            
//                            if (try >= 6) {
//                                break;
//                            }
//                        }
//                        
//                        if (!isImageReadable(path)) {
//                            NSString* msg = [NSString stringWithFormat:@"%@ 解密失败！", path.lastPathComponent];
//                            [[NSAlert alertWithMessageText:msg defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil] runModal];
//                            return;
//                        }
//                        EncryptFile(path);
//                    }
//                }
//                    break;
//                default:
//                    break;
//            }
//        }
//    }
//}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        if (argc != 2) {
            NSLog(@"using: file-sort [folder-path] to make sorted files");
            return -1;
        }
        
        NSString* path = [NSString stringWithUTF8String:argv[1]];
        NSFileManager* fmgr = [NSFileManager defaultManager];
        
        BOOL isDirectory = NO;
        BOOL exist = [fmgr fileExistsAtPath:path isDirectory:&isDirectory];
        
        if (!(exist && isDirectory)) {
            NSLog(@"using: file-sort [folder-path] to make sorted files");
            return -1;
        }
        
        NSArray* array = [fmgr subpathsAtPath:path];
        if (array.count) {
            NSString* prefix = [path.lastPathComponent stringByAppendingString:@"_"];
            NSString* src_folder = path;
            NSString* des_folder = [path stringByAppendingString:@"_sort"];
            [fmgr removeItemAtPath:des_folder error:nil];
            [fmgr createDirectoryAtPath:des_folder withIntermediateDirectories:YES attributes:nil error:nil];
            
            for (NSString* name in array) {
                NSString* des_name = [[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
                
                NSString* src_path = [src_folder stringByAppendingPathComponent:name];
                
                BOOL isDirectory = NO;
                BOOL exist = [fmgr fileExistsAtPath:src_path isDirectory:&isDirectory];
                if (exist && isDirectory) {
                    NSLog(@"pass folder [%@]", src_path);
                    continue;
                }
                
                NSString* des_path = [des_folder stringByAppendingPathComponent:[prefix stringByAppendingString:des_name]];
                
                NSError* err = nil;
                if (![fmgr copyItemAtPath:src_path toPath:des_path error:&err]) {
                    NSLog(@"copy [%@] to [%@] failed!", src_path, des_path);
                    return -1;
                }
                
                NSLog(@"copied [%@] to [%@] !", src_path, des_path);
            }
        }
    }
    return 0;
}
