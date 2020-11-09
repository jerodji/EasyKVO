//
//  BBViewController.m
//  KVODemo
//
//  Created by Jerod on 2020/11/3.
//

#import "BBViewController.h"
#import "Person.h"

#import "NSObject+EasyKVO.h"
//#import "NSObject+XZKVO.h"
#import "EasyKVO.h"
#import "NSString+kvo.h"

@interface BBViewController ()
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) Person *person;
@property (nonatomic, strong) NSMutableArray *arr;
@end

@implementation BBViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"BB init");
    }
    return self;
}

//- (void)ttAction {
//    [self.arr removeAllObjects];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.title = @"BB";
    
    self.msg = @"1";
    self.person = [[Person alloc] init];
    self.person.name = @"name";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"change" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(100, 100, 100, 60);
    [self.view addSubview:btn];
    
    
//    self.arr = [NSMutableArray array];
//    Person *p = [[Person alloc] init];
//    [self.arr addObject:p];
//    UIButton *tt = [UIButton buttonWithType:UIButtonTypeSystem];
//    [tt setTitle:@"tt" forState:UIControlStateNormal];
//    [tt addTarget:self action:@selector(ttAction) forControlEvents:UIControlEventTouchUpInside];
//    tt.frame = CGRectMake(100, 200, 100, 60);
//    [self.view addSubview:tt];
    
    
    // MARK: KVO
//    [self addObserver:self forKeyPath:@"msg" options:NSKeyValueObservingOptionNew context:nil];
//    [self addObserver:self forKeyPath:@"person.name" options:NSKeyValueObservingOptionNew context:nil];
    
    
    NSLog(@"addObserver");
    
    
    // MARK: easy KVO
    
   
//    [self.person observeProperty:@"name" changedBlock:^(id newValue, id oldValue) {
//        NSLog(@" > person.name : 旧值 %@, 新值 %@", oldValue, newValue);
//    }];
//    [self.person observeProperty:@"nick" changedBlock:^(id newValue, id oldValue) {
//        NSLog(@" > person.nick : 旧值 %@, 新值 %@", oldValue, newValue);
//    }];

//    [self observeProperty:@"msg" changedBlock:^(id newValue, id oldValue) {
//        NSLog(@" > msg : 旧值 %@, 新值 %@", oldValue, newValue);
//    }];
    
//    [self observe:self forKeyPath:@"msg" changedBlock:^(id newValue, id oldValue) {
//        NSLog(@" > msg : 旧值 %@, 新值 %@", oldValue, newValue);
//    }];
//    [self observe:self.person forKeyPath:@"name" changedBlock:^(id newValue, id oldValue) {
//        NSLog(@" > person.name : 旧值 %@, 新值 %@", oldValue, newValue);
//    }];
    
    [self watchKeyPath:@"msg" changedBlock:^(id newValue, id oldValue) {
        NSLog(@" > msg : 旧值 %@, 新值 %@", oldValue, newValue);
    }];
    
    [self.person watchKeyPath:@"name" changedBlock:^(id newValue, id oldValue) {
        NSLog(@" > person.name : 旧值 %@, 新值 %@", oldValue, newValue);
    }];
    

    
    [self watchKeyPath:@"text" changedBlock:^(id newValue, id oldValue) {
        NSLog(@" > text : 旧值 %@, 新值 %@", oldValue, newValue);
    }];
    
    [self.person watchKeyPath:@"nick" changedBlock:^(id newValue, id oldValue) {
        NSLog(@" > person.nick : 旧值 %@, 新值 %@", oldValue, newValue);
    }];
    
}
//
//- (void)dealloc
//{
//    NSLog(@">>> BBViewController dealloc");
//}

- (void)clickAction:(UIButton*)sender {
    NSString *letter = [NSString stringWithFormat:@"%ld", self.msg.integerValue + 1];
    self.msg = letter;
    self.text = letter;
    self.person.name = letter;
    self.person.nick = letter;
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    
//    if ([keyPath isEqualToString:@"msg"]) {
//        NSLog(@"msg 新值 : %@", self.msg);
//    }
//    if ([keyPath isEqualToString:@"person.name"]) {
//        NSLog(@"person.name 新值 : %@", self.person.name);
//    }
//}


@end