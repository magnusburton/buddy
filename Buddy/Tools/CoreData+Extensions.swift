//
//  CoreDataExtension.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-07-27.
//

import CoreData

public extension NSManagedObject {
	
	convenience init(using context: NSManagedObjectContext) {
		let name = String(describing: type(of: self))
		let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
		self.init(entity: entity, insertInto: context)
	}
	
}
