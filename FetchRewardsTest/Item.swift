//
//  Item.swift
//  FetchRewardsTest
//
//  Created by Saranya Kalyanasundaram on 9/16/20.
//  Copyright © 2020 Saranya. All rights reserved.
//

import Foundation

struct Item : Codable{
    let id : Int
    let listId : Int
    let name : String?
}

struct List {
    let id : Int
    let items : [Item]

    static func group (items : [Item]) -> [List]{
        //create a dictionary of list items keyed by listId
        let groups = Dictionary.init(grouping: items) { (item) -> Int in
            return item.listId
        }
       //sort dictionary by listID
        let dictSortedByListId = groups.sorted {
            $0.key < $1.key
        }
        //map each element of dictionary into a List Struct intialized with items sorted by their names
        let listOfSortedItems = dictSortedByListId.map { (key,value) -> List in
            
            return List(id: key, items: self.sortItemsByNames(items: value))
            
        }
        return listOfSortedItems
    }
    
    static func sortItemsByNames(items : [Item]) -> [Item]{
        
        let sortedItems = items.sorted(by: { (item1, item2) -> Bool in
            guard let name1 = item1.name, let name2 = item2.name else{
                return false
            }
            if let codeString1 = name1.split(separator: " ").last, let codeString2 = name2.split(separator: " ").last{
                if let code1 = Int(String(codeString1)), let code2 = Int(String(codeString2)){
                    return  code1 < code2
                }
               
            }else{
                return name1 < name2
            }
            return item1.id < item2.id
        })
        return sortedItems
    }
}
