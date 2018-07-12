//
//  TestSignalOfStreamMethodTests.m
//  TestSignalOfStreamMethodTests
//
//  Created by ys on 2018/7/12.
//  Copyright © 2018年 ys. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <ReactiveCocoa.h>

@interface TestSignalOfStreamMethodTests : XCTestCase

@end

@implementation TestSignalOfStreamMethodTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - 测试所需信号
// 创建一个信号（发送一串数字）
- (RACSignal *)createSignal1
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        for (int i = 0; i < 10; i++) {
            [subscriber sendNext:@(i)];
        }
        [subscriber sendCompleted];
        
        return nil;
    }];
}
// 创建一个信号（发送一串信号）
- (RACSignal *)createSignal2
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        for (int i = 0; i < 10; i++) {
            [subscriber sendNext:[RACSignal return:@(i)]];
        }
        [subscriber sendCompleted];
        
        return nil;
    }];
}
// 创建一个信号（发送一个元祖）
- (RACSignal *)createSignal3
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:[RACTuple tupleWithObjects:@(1), @(2), nil]];
        [subscriber sendCompleted];
        
        return nil;
    }];
}
// 创建一个信号（发送一个元祖）
- (RACSignal *)createSignal4
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSArray *array = @[@(1), @(1), @(2), @(2), @(2), @(4), @(8)];
        for (NSNumber *number in array) {
            [subscriber sendNext:number];
        }
        [subscriber sendCompleted];
        
        return nil;
    }];
}

#pragma mark - 测试方法
- (void)testFlattenMap
{
    [[[self createSignal1] flattenMap:^RACStream *(id value) {
        NSNumber *number = (NSNumber *)value;
        return [RACSignal return:@([number intValue] * [number intValue])];
    }]
     subscribeNext:^(id x) {
         printf("flattenMap -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     flattenMap -- 0
     flattenMap -- 1
     flattenMap -- 4
     flattenMap -- 9
     flattenMap -- 16
     flattenMap -- 25
     flattenMap -- 36
     flattenMap -- 49
     flattenMap -- 64
     flattenMap -- 81
     */
}

- (void)testFlatten
{
    [[[self createSignal2] flatten]
     subscribeNext:^(id x) {
         printf("flatten -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     flatten -- 0
     flatten -- 1
     flatten -- 2
     flatten -- 3
     flatten -- 4
     flatten -- 5
     flatten -- 6
     flatten -- 7
     flatten -- 8
     flatten -- 9
     */
}

- (void)testMap
{
    [[[self createSignal1] map:^id(id value) {
        NSNumber *number = (NSNumber *)value;
        return @([number intValue] + 1);
    }]
     subscribeNext:^(id x) {
         printf("map -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     map -- 1
     map -- 2
     map -- 3
     map -- 4
     map -- 5
     map -- 6
     map -- 7
     map -- 8
     map -- 9
     map -- 10
     */
}

- (void)testMapReplace
{
    [[[self createSignal1] mapReplace:@(100)]
     subscribeNext:^(id x) {
         printf("mapReplace -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     mapReplace -- 100
     mapReplace -- 100
     mapReplace -- 100
     mapReplace -- 100
     mapReplace -- 100
     mapReplace -- 100
     mapReplace -- 100
     mapReplace -- 100
     mapReplace -- 100
     mapReplace -- 100
     */
}

- (void)testCombinePrevious
{
    [[[self createSignal1] combinePreviousWithStart:@(1) reduce:^id(id previous, id current) {
        return @([previous intValue] + [current intValue]);
    }]
     subscribeNext:^(id x) {
         printf("combinePrevious -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     combinePrevious -- 1
     combinePrevious -- 1
     combinePrevious -- 3
     combinePrevious -- 5
     combinePrevious -- 7
     combinePrevious -- 9
     combinePrevious -- 11
     combinePrevious -- 13
     combinePrevious -- 15
     combinePrevious -- 17

     */
}
- (void)testScan
{
    [[[self createSignal1] scanWithStart:@(1) reduce:^id(id running, id next) {
        return @([running intValue] + [next intValue]);
    }]
     subscribeNext:^(id x) {
         printf("scan -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     scan -- 1
     scan -- 2
     scan -- 4
     scan -- 7
     scan -- 11
     scan -- 16
     scan -- 22
     scan -- 29
     scan -- 37
     scan -- 46
     */
}

- (void)testScanIndex
{
    [[[self createSignal1] scanWithStart:@(1) reduceWithIndex:^id(id running, id next, NSUInteger index) {
        return @([running intValue] + [next intValue]);
    }]
     subscribeNext:^(id x) {
         printf("scanIndex -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     scanIndex -- 1
     scanIndex -- 2
     scanIndex -- 4
     scanIndex -- 7
     scanIndex -- 11
     scanIndex -- 16
     scanIndex -- 22
     scanIndex -- 29
     scanIndex -- 37
     scanIndex -- 46
     */
}
/*
 注意此处两个函数的区别。
 1、scan 函数 完成的是当前值与上一个值的运算,并将结果存储下来，当下一个值到来时作为下一个值的上一个值参与运算。
 __block id running = startingValue;
 __block NSUInteger index = 0;
 
 return ^(id value, BOOL *stop) {
 running = reduceBlock(running, value, index++);
 return [class return:running];
 };
 如代码所示：当value来到时，参与运算的running就是上一个值，然后保存下来并作为最终结果。下次再次有value来时，running同样会做相同的操作。
 2、combinePrevious 函数 是单独一个信号当前值与上一个值的运算，并返回。
 [[[self
 scanWithStart:RACTuplePack(start)
 reduce:^(RACTuple *previousTuple, id next) {
 id value = reduceBlock(previousTuple[0], next);
 return RACTuplePack(next, value);
 }]
 map:^(RACTuple *tuple) {
 return tuple[1];
 }]
 通过reduceBlock做运算然后通过return tuple[1];返回运算结果，同时next作为previousTuple[0]参与下次的运算。
 
 如果还是有点不懂，可以尝试在本子上写出来，或者将start设置为@(0)。
 */

- (void)testFilter
{
    [[[self createSignal1] filter:^BOOL(id value) {
        return [value intValue] > 8;
    }]
     subscribeNext:^(id x) {
         printf("filter -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     filter -- 9
     */
}

- (void)testIgnore
{
    [[[self createSignal1] ignore:@(9)]
     subscribeNext:^(id x) {
         printf("ignore -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     ignore -- 0
     ignore -- 1
     ignore -- 2
     ignore -- 3
     ignore -- 4
     ignore -- 5
     ignore -- 6
     ignore -- 7
     ignore -- 8
     */
}

- (void)testRecudeEach
{
    [[[self createSignal3] reduceEach:^id (NSNumber *first, NSNumber *second){
        return @([first intValue] - [second intValue]);
    }]
     subscribeNext:^(id x) {
         printf("reduceEach -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     reduceEach -- -1
     */
}

- (void)testStart
{
    [[[self createSignal1] startWith:@(100)]
     subscribeNext:^(id x) {
         printf("start -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     start -- 100
     start -- 0
     start -- 1
     start -- 2
     start -- 3
     start -- 4
     start -- 5
     start -- 6
     start -- 7
     start -- 8
     start -- 9
     */
}

- (void)testConcat
{
    [[[self createSignal1] concat:[self createSignal1]]
     subscribeNext:^(id x) {
         printf("concat -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     concat -- 0
     concat -- 1
     concat -- 2
     concat -- 3
     concat -- 4
     concat -- 5
     concat -- 6
     concat -- 7
     concat -- 8
     concat -- 9
     concat -- 0
     concat -- 1
     concat -- 2
     concat -- 3
     concat -- 4
     concat -- 5
     concat -- 6
     concat -- 7
     concat -- 8
     concat -- 9
     */
}

- (void)testSkip
{
    [[[self createSignal1] skip:8]
     subscribeNext:^(id x) {
         printf("skip -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     skip -- 8
     skip -- 9
     */
}

- (void)testTake
{
    [[[self createSignal1] take:8]
     subscribeNext:^(id x) {
         printf("take -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     take -- 0
     take -- 1
     take -- 2
     take -- 3
     take -- 4
     take -- 5
     take -- 6
     take -- 7
     */
}

- (void)testZip
{
    [[RACSignal zip:@[[self createSignal1], [self createSignal1]]]
     subscribeNext:^(id x) {
         NSLog(@"zip -%@", x);
     }];
    
    /*
     输出日志
     2018-07-12 15:05:58.183277+0800 TestSignalOfStreamMethod[60684:3611304] zip -<RACTuple: 0x60400000d750> (
     0,
     0
     )
     2018-07-12 15:05:58.183541+0800 TestSignalOfStreamMethod[60684:3611304] zip -<RACTuple: 0x60400000d770> (
     1,
     1
     )
     2018-07-12 15:05:58.183743+0800 TestSignalOfStreamMethod[60684:3611304] zip -<RACTuple: 0x60400000d790> (
     2,
     2
     )
     2018-07-12 15:05:58.183938+0800 TestSignalOfStreamMethod[60684:3611304] zip -<RACTuple: 0x60400000d7b0> (
     3,
     3
     )
     2018-07-12 15:05:58.184298+0800 TestSignalOfStreamMethod[60684:3611304] zip -<RACTuple: 0x600000017fe0> (
     4,
     4
     )
     2018-07-12 15:05:58.184618+0800 TestSignalOfStreamMethod[60684:3611304] zip -<RACTuple: 0x600000018000> (
     5,
     5
     )
     2018-07-12 15:05:58.184823+0800 TestSignalOfStreamMethod[60684:3611304] zip -<RACTuple: 0x600000018020> (
     6,
     6
     )
     2018-07-12 15:05:58.185038+0800 TestSignalOfStreamMethod[60684:3611304] zip -<RACTuple: 0x600000018040> (
     7,
     7
     )
     2018-07-12 15:05:58.185226+0800 TestSignalOfStreamMethod[60684:3611304] zip -<RACTuple: 0x600000018070> (
     8,
     8
     )
     2018-07-12 15:05:58.185407+0800 TestSignalOfStreamMethod[60684:3611304] zip -<RACTuple: 0x600000018090> (
     9,
     9
     )
     */
}

- (void)testZipReduce
{
    
    [[RACSignal zip:@[[self createSignal1], [self createSignal1]] reduce:^id(NSNumber *first, NSNumber *second){
        return @([first intValue] + [second intValue]);
    }]
     subscribeNext:^(id x) {
         printf("ZipReduce -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     ZipReduce -- 0
     ZipReduce -- 2
     ZipReduce -- 4
     ZipReduce -- 6
     ZipReduce -- 8
     ZipReduce -- 10
     ZipReduce -- 12
     ZipReduce -- 14
     ZipReduce -- 16
     ZipReduce -- 18
     */
}

- (void)testConcat1
{
    
    [[RACSignal concat:@[[self createSignal1], [self createSignal1]]]
     subscribeNext:^(id x) {
         printf("concat -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     concat -- 0
     concat -- 1
     concat -- 2
     concat -- 3
     concat -- 4
     concat -- 5
     concat -- 6
     concat -- 7
     concat -- 8
     concat -- 9
     concat -- 0
     concat -- 1
     concat -- 2
     concat -- 3
     concat -- 4
     concat -- 5
     concat -- 6
     concat -- 7
     concat -- 8
     concat -- 9
     */
}

- (void)testTakeUntilBlock
{
    [[[self createSignal1] takeUntilBlock:^BOOL(id x) {
        NSNumber *number = (NSNumber *)x;
        return [number intValue] > 8;
    }]
     subscribeNext:^(id x) {
         printf("takeUntilBlock -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     takeUntilBlock -- 0
     takeUntilBlock -- 1
     takeUntilBlock -- 2
     takeUntilBlock -- 3
     takeUntilBlock -- 4
     takeUntilBlock -- 5
     takeUntilBlock -- 6
     takeUntilBlock -- 7
     takeUntilBlock -- 8
     */
}

- (void)testTakeWhileBlock
{
    [[[self createSignal1] takeWhileBlock:^BOOL(id x) {
        NSNumber *number = (NSNumber *)x;
        return [number intValue] < 8;
    }]
     subscribeNext:^(id x) {
         printf("takeWhileBlock -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     takeWhileBlock -- 0
     takeWhileBlock -- 1
     takeWhileBlock -- 2
     takeWhileBlock -- 3
     takeWhileBlock -- 4
     takeWhileBlock -- 5
     takeWhileBlock -- 6
     takeWhileBlock -- 7
     */
}

- (void)testSkipUntilBlock
{
    [[[self createSignal1] skipUntilBlock:^BOOL(id x) {
        NSNumber *number = (NSNumber *)x;
        return [number intValue] > 8;
    }]
     subscribeNext:^(id x) {
         printf("skipUntilBlock -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     skipUntilBlock -- 9
     */
}

- (void)testSkipWhileBlock
{
    [[[self createSignal1] skipWhileBlock:^BOOL(id x) {
        NSNumber *number = (NSNumber *)x;
        return [number intValue] < 8;
    }]
     subscribeNext:^(id x) {
         printf("skipWhileBlock -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     skipWhileBlock -- 8
     skipWhileBlock -- 9
     */
}

- (void)testDistinctUntilChanged
{
    [[[self createSignal4] distinctUntilChanged]
     subscribeNext:^(id x) {
         printf("distinctUntilChanged -- %d\n", [x intValue]);
     }];
    
    /*
     输出日志
     distinctUntilChanged -- 1
     distinctUntilChanged -- 2
     distinctUntilChanged -- 4
     distinctUntilChanged -- 8
     */
}

@end
