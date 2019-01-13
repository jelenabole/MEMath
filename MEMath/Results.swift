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
    
    init(from object: NSManagedObject) {
        (self.username, self.time, self.points, self.flips, self.difficulty) = (object.value(forKey: "username"), object.value(forKey: "time"), object.value(forKey: "points"), object.value(forKey: "flips"), object.value(forKey: "difficulty")) as! (String, String, Int, Int, Int)
    }
}

class DatabaseResults {
    
    let context: NSManagedObjectContext?;
    let max: Int?;
    
    init(from context: NSManagedObjectContext, maxScores number: Int) {
        self.context = context;
        self.max = number;
    }
    
    
    // get items
    func getItems(for difficulty: Deck.Difficulty? = nil) -> [PlayerResult] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Results");
        
        if let diff = difficulty {
            // fetchRequest.predicate = NSPredicate(format: "difficulty == %@", diff.rawValue);
            fetchRequest.predicate = NSPredicate(format: "difficulty == \(diff.rawValue)");
        }
        let sortDescriptor = NSSortDescriptor(key: "points", ascending: true);
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
            
            // TODO - obtained results - return as a plain object
            var playerResults: [PlayerResult] = [];
            for item in obtainedResults {
                playerResults.append(PlayerResult(from: item));
            }
            return playerResults;
        } catch {
            print("Error while getting value from DB");
        }
        
        return [];
    }
    
    
    // DB method
    func getDatabaseObjects(for difficulty: Int? = nil) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Results");
        
        if let diff = difficulty {
            fetchRequest.predicate = NSPredicate(format: "difficulty == \(diff)");
        }
        let sortDescriptor = NSSortDescriptor(key: "points", ascending: true);
        fetchRequest.sortDescriptors = [sortDescriptor];
        
        do {
            let results = try context!.fetch(fetchRequest);
            let obtainedResults = results as! [NSManagedObject];
            
            return obtainedResults;
        } catch {
            print("Error while getting value from DB");
        }
        
        return [];
    }
    
    // save player result to context:
    func save(item: PlayerResult, as name: String) {
        // create new results:
        let entity = NSEntityDescription.entity(forEntityName: "Results", in: context!);
        let myItem = NSManagedObject(entity: entity!, insertInto: context);
        
        myItem.setValue(name, forKey: "username");
        myItem.setValue(item.time, forKey: "time");
        myItem.setValue(item.points, forKey: "points");
        myItem.setValue(item.flips, forKey: "flips");
        myItem.setValue(item.difficulty, forKey: "difficulty");
        
        saveChanges();
        deleteUnnecessary(for: item.difficulty);
    }
    
    func deleteUnnecessary(for difficulty: Int) {
        // get all of them, and delete last few:
        let users = getDatabaseObjects(for: difficulty);
        print("delete unnecessary users from: \(users.count)");
        
        // go through all users and delete them
        for index in max! ..< users.count {
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
    
    
    
    
    // delete user
    func delete(user object: NSManagedObject) {
        context!.delete(object);
        saveChanges();
    }
    
    // TODO - test = delete all users:
    func deleteAll() {
        let users = getDatabaseObjects();
        print("delete \(users.count) users!");
        
        // go through all users and delete them
        for index in 0 ..< users.count {
            context!.delete(users[index]);
        }
        saveChanges();
    }
    
    func printAll(users: [NSManagedObject]) {
        for index in 0 ..< users.count {
            let user = users[index];
            
            let username = user.value(forKey: "username")!;
            let time = user.value(forKey: "time")!;
            let points = user.value(forKey: "points")!;
            let flips = user.value(forKey: "flips")!;
            let difficulty = user.value(forKey: "difficulty")!;
            
            print("\(index) = username: \(username) \t - time: \(time)  - points: \(points) - flips: \(flips) - diff: \(difficulty)");
        }
    }
    
}
