//
//  main.m
//  file-sort
//
//  Created by HanShaokun on 21/8/15.
//  Copyright (c) 2015 by. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* numString(NSString* str)
{
    NSString* num = @"0123456789";
    NSMutableString* ret = [NSMutableString stringWithString:@""];
    
    for (int i = 0; i < str.length; i++) {
        NSString* o = [str substringWithRange:NSMakeRange(i, 1)];
        if ([num rangeOfString:o].location != NSNotFound) {
            [ret appendString:o];
        }
        else {
            if (ret.length > 0) {
                NSString* e = [ret substringFromIndex:ret.length - 1];
                if ([num rangeOfString:e].location != NSNotFound) {
                    [ret appendString:@"."];
                }
            }
        }
    }
    
    return ret;
}

NSComparisonResult compareNumString(NSString* n1, NSString* n2)
{
    NSArray *a1 = [n1 componentsSeparatedByString:@"."];
    NSArray *a2 = [n2 componentsSeparatedByString:@"."];
    
    if ([a1 count] < [a2 count]) {
        return NSOrderedAscending;
    }
    else if ([a1 count] > [a2 count]) {
        return NSOrderedDescending;
    }
    else {
        for (int i = 0; i < a1.count; i++) {
            long long step1 = [a1[i] longLongValue];
            long long step2 = [a2[i] longLongValue];
            
            if (step1 < step2) {
                return NSOrderedAscending;
            }
            else if (step1 > step2) {
                return NSOrderedDescending;
            }
        }
    }
    
    return NSOrderedSame;;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSMutableArray* args = [NSMutableArray array];
        for (int i = 0; i < argc; i++) {
            [args addObject:[NSString stringWithUTF8String:argv[i]]];
        }
        
        NSMutableArray *keys = [NSMutableArray array];
        NSMutableArray *values = [NSMutableArray array];
        
        bool start = false;
        for (int i = 0; i < argc; i++) {
            
            if ([args[i] hasPrefix:@"-"]) {
                [keys addObject:[args[i] substringFromIndex:1]];
                start = true;
            }
            else {
                if (start) {
                    [values addObject:args[i]];
                }
            }
        }
        
        NSLog(@"%@", keys);
        NSLog(@"%@", values);
        
        if (!keys.count || keys.count != values.count) {
            printf("\n\t\t***** file-sort *****\n");
            printf("\t参数:\n");
            printf("\t-f folder_path\t\t使用文件夹内的文件\n");
            printf("\t-p prefix\t\t使用以 prefix 为前缀的文件\n");
            printf("\t-s suffix\t\t使用以 suffix 为后缀的文件\n");
            printf("\t-ap key\t\t\t所有文件名前添加 key\n");
            printf("\t-as key\t\t\t所有文件名后添加 key\n");
            printf("\t-r key\t\t\t所有文件名内移除 key\n");
            printf("\t-rp key\t\t\t所有文件名前移除 key\n");
            printf("\t-rs key\t\t\t所有文件名后移除 key\n");
            printf("\t-e key\t\t\t所有文件设置后缀为\n");
            printf("\t-n 0\t\t\t所有文件排序后从0开始命名\n\n");
            return -1;
        }
        
        NSMutableDictionary* _params = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
        
        if (!_params[@"m"]) {
            _params[@"m"] = @"0";
        }
        
        NSString* src_folder = _params[@"f"];
        if (!src_folder || [src_folder isEqualToString:@"."]) {
            src_folder = @"";
        }
        if (![src_folder hasPrefix:@"/"]) {
            src_folder = [[NSString stringWithUTF8String:getcwd(NULL, 1024)] stringByAppendingString:src_folder];
        }
        
        NSString* des_name = src_folder.lastPathComponent;
        if (_params[@"s"] && _params[@"p"]) {
            des_name = [[_params[@"p"] stringByAppendingString:src_folder.lastPathComponent] stringByAppendingString:_params[@"s"]];
        }
        else if (_params[@"s"]) {
            des_name = _params[@"s"];
        }
        else if (_params[@"p"]) {
            des_name = _params[@"p"];
        }
        
        NSString* des_folder = [[src_folder stringByDeletingLastPathComponent] stringByAppendingPathComponent:des_name];
        
        NSFileManager* fmgr = [NSFileManager defaultManager];
        
//        [fmgr removeItemAtPath:des_folder error:nil];
        [fmgr createDirectoryAtPath:des_folder withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSLog(@"src_folder %@", src_folder);
        
        BOOL isDirectory = NO;
        BOOL exist = [fmgr fileExistsAtPath:src_folder isDirectory:&isDirectory];
        
        if (!(exist && isDirectory)) {
            printf("\n\t\t***** file-sort *****\n");
            printf("\t参数:\n");
            printf("\t-f folder_path\t\t使用文件夹内的文件\n");
            printf("\t-p prefix\t\t以 key 为前缀的文件\n");
            printf("\t-s suffix\t\t以 key 为后缀的文件\n");
            printf("\t-ap key\t\t\t所有文件名前添加 key\n");
            printf("\t-as key\t\t\t所有文件名后添加 key\n");
            printf("\t-r key\t\t\t所有文件名内移除 key\n");
            printf("\t-rp key\t\t\t所有文件名前移除 key\n");
            printf("\t-rs key\t\t\t所有文件名后移除 key\n");
            printf("\t-e key\t\t\t所有文件设置后缀为\n");
            printf("\t-n 0\t\t\t所有文件排序后从0开始命名\n\n");
            return -1;
        }
        
        NSArray* array = [fmgr contentsOfDirectoryAtPath:src_folder error:nil];
        
        if (_params[@"s"] || _params[@"p"]) {
            NSMutableArray* new_array = [NSMutableArray array];
            for (int i = 0; i < array.count; i++) {
                NSString* name = array[i];
                
                if (_params[@"p"] && [name hasPrefix:_params[@"p"]]) {
                    [new_array addObject:name];
                }
                
                if (_params[@"s"] && [name hasSuffix:_params[@"s"]]) {
                    [new_array addObject:name];
                }
            }
            array = new_array;
        }
        
        array = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString* n1 = numString([obj1 stringByDeletingPathExtension]);
            NSString* n2 = numString([obj2 stringByDeletingPathExtension]);
            
            return compareNumString(n1, n2);
        }];
        
        NSLog(@"%@", array);
        
        int cnt = 0;
        int power10 = 0;
        for (int i = 0; i < 100; i++) {
            power10 = pow(10, i);
            if (power10 >= array.count) {
                cnt = i - 1;
                break;
            }
        }
        
        NSString* numFormat = @"%d";
        if (cnt > 1) {
            numFormat = [NSString stringWithFormat:@"%%0%dd", cnt];
        }
        
        int j = 0;
        for (int i = 0; i < array.count; i++) {
            NSString* name = array[i];
            
            if ([name isEqualToString:@".DS_Store"]) {
                continue;
            }
            
            NSString* sn = [name stringByDeletingPathExtension];
            NSString* en = [name pathExtension];
            if ([_params[@"e"] length]) {
                en = _params[@"e"];
                if (![[[name pathExtension] lowercaseString] isEqualToString:en]) {
                    continue;
                }
            }
            
            if ([_params[@"n"] length]) {
                sn = [NSString stringWithFormat:numFormat, j + [_params[@"n"] longLongValue]];
                j++;
            }
            else {
                if ([_params[@"rp"] length]) {
                    if ([sn hasPrefix:_params[@"rp"]]) {
                        sn = [sn substringFromIndex:[_params[@"rp"] length]];
                    }
                }
                
                if ([_params[@"rs"] length]) {
                    if ([sn hasSuffix:_params[@"rs"]]) {
                        sn = [sn substringToIndex:sn.length - [_params[@"rs"] length]];
                    }
                }
                
                if ([_params[@"r"] length]) {
                    sn = [sn stringByReplacingOccurrencesOfString:_params[@"r"] withString:@""];
                }
            }
            
            if ([_params[@"ap"] length]) {
                sn = [_params[@"ap"] stringByAppendingString:sn];
            }
            
            if ([_params[@"as"] length]) {
                sn = [sn stringByAppendingString:_params[@"as"]];
            }
            
            NSString* src_path = [src_folder stringByAppendingPathComponent:name];
            NSString* des_path = [des_folder stringByAppendingPathComponent:[sn stringByAppendingPathExtension:en]];
            
            if ([_params[@"m"] isEqualToString:@"0"]) {
                NSError* err = nil;
                if (![fmgr copyItemAtPath:src_path toPath:des_path error:&err]) {
                    NSLog(@"copy [%@] to [%@] failed!", src_path, des_path);
                }
                else {
                    NSLog(@"copied [%@] to [%@] !", src_path, des_path);
                }
            }
            else {
                NSError* err = nil;
                if (![fmgr moveItemAtPath:src_path toPath:des_path error:&err]) {
                    NSLog(@"move [%@] to [%@] failed!", src_path, des_path);
                }
                else {
                    NSLog(@"moved [%@] to [%@] !", src_path, des_path);
                }
            }
        }
    }
    return 0;
}
