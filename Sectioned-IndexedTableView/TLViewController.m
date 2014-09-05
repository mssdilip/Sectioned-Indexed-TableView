//
//  TLViewController.m
//  Sectioned-IndexedTableView
//
//  Created by Thien Liu on 9/5/14.
//  Copyright (c) 2014 Thien Liu. All rights reserved.
//

/**********
 
 1. Load tableview's datasource from plist file
 2. Use UILocalizedIndexedCollation to configure data
 3. Set up a sectioned indexed table view
 
 *********/

#import "TLViewController.h"

@interface TLViewController ()

@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NSMutableArray *outerArray;
@property (nonatomic, strong) UILocalizedIndexedCollation *collation;

@end

@implementation TLViewController

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"Names" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:fileName];
    self.tableData = dic[@"names"];
    [self configureTableData];
}

#pragma mark - Helper methods

- (void)configureTableData {
    self.collation = [UILocalizedIndexedCollation currentCollation];
    NSUInteger sectionTitlesCount = [self.collation.sectionTitles count];
    self.outerArray = [NSMutableArray arrayWithCapacity:sectionTitlesCount];
    
    for (int index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [self.outerArray addObject:array];
    }
    
    for (NSString *nameString in self.tableData) {
        NSUInteger nameSectionNumber = [self.collation sectionForObject:nameString
                                                collationStringSelector:@selector(lowercaseString)];
        [self.outerArray[nameSectionNumber] addObject:nameString];
    }
    
    for (int index = 0; index < sectionTitlesCount; index++) {
        NSArray *sortNameStrings = [self.collation sortedArrayFromArray:self.outerArray[index]
                                                collationStringSelector:@selector(lowercaseString)];
        [self.outerArray replaceObjectAtIndex:index withObject:sortNameStrings];
    }
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.collation.sectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.outerArray[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *letter = self.collation.sectionTitles[section];
    if (![letter isEqualToString:@"#"]) {
        if ([self.outerArray[section] count] > 0) {
            return letter;
        }
    }
    return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.collation.sectionTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.collation sectionForSectionIndexTitleAtIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSArray *innerArray = self.outerArray[indexPath.section];
    cell.textLabel.text = innerArray[indexPath.row];
    return cell;
}

@end
