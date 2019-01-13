//
//  Results.swift
//  MEMath
//
//  Created by Jelena on 10/01/2019.
//  Copyright © 2019 Jelena. All rights reserved.
//

import Foundation
import CoreData

class PlayerResult {
    var username: String;
    var time: String;
    var points: Int;
    var flips: Int;
    var difficulty: Int;
    
    init(username: String, time: String, points: Int, flips: Int, difficulty: Int) {
        (self.username, self.time, self.points, self.flips, self.difficulty) = (username, time, points, flips, difficulty);
    }
}

class DatabaseResults {
    
    let context: NSManagedObjectContext?;
    
    init(from context: NSManagedObjectContext) {
        self.context = context;
    }
    
    
    // get items
    func getItems(for difficulty: Deck.Difficulty? = nil) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Results");
        
        if let diff = difficulty {
            // fetchRequest.predicate = NSPredicate(format: "difficulty == %@", diff.rawValue);
            fetchRequest.predicate = NSPredicate(format: "difficulty == \(diff.rawValue)");
        }
        let sortDescriptor = NSSortDescriptor(key: "points", ascending: false);
        fetchRequest.sortDescriptors = [sortDescriptor];
        
        do {
            let results = try context!.fetch(fetchRequest);
            let obtainedResults = results as! [NSManagedObject];
            
            // TODO - print all users:
            printAll(users: obtainedResults);
            
            // TODO - test:
            if (obtainedResults.count == 0) {
                print("** no results for this filter");
            } else {
                print ("** number of entries: \(obtainedResults.count)");
            }
            return obtainedResults
        } catch {
            print("Error while getting value from DB");
        }
        return [];
    }
    
    // save player result to context:
    func save(item: PlayerResult) {
        // create new results:
        let entity = NSEntityDescription.entity(forEntityName: "Results", in: context!);
        let myItem = NSManagedObject(entity: entity!, insertInto: context);
        
        myItem.setValue(item.username, forKey: "username");
        myItem.setValue(item.time, forKey: "time");
        myItem.setValue(item.points, forKey: "points");
        myItem.setValue(item.flips, forKey: "flips");
        myItem.setValue(item.difficulty, forKey: "difficulty");
        
        saveChanges();
    }
    
    // TODO - used in game controller to save new entered user score
    func save(player name: String, time seconds: Int, flips tries: Int, difficulty level: Int) {
        // add player to the list
        print("fix time in database.save");
        let result = PlayerResult(username: name, time: "0:30", points: seconds, flips: tries, difficulty: level);
        save(item: result);
    }
    
    // delete user
    func delete(user object: NSManagedObject) {
        context!.delete(object);
        saveChanges();
    }
    
    // TODO - test = delete all users:
    func deleteAll() {
        let users = getItems();
        print("delete \(users.count) users!");
        
        // go through all users and delete them
        for index in 0 ..< users.count {
            context!.delete(users[index]);
        }
        saveChanges();
    }
    
    // save any changed (add, update, delete):
    func saveChanges() {
        do {
            try context!.save();
        } catch {
            print("There was an error in saving data!");
        }
    }
    
    
    
    
    
    func printAll(users: [NSManagedObject]) {
        for index in 0 ..< users.count {
            let user = users[index];
            
            let username = user.value(forKey: "username")!;
            let time = user.value(forKey: "time")!;
            let points = user.value(forKey: "points")!;
            let flips = user.value(forKey: "flips")!;
            let difficulty = user.value(forKey: "difficulty")!;
            
            print("\(index) = username: \(username) - time: \(time)  - points: \(points) - diff: \(difficulty)");
        }
    }
    
}
