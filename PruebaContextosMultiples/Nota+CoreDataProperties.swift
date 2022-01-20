//
//  Nota+CoreDataProperties.swift
//  PruebaContextosMultiples
//
//  Created by Otto Colomina Pardo on 20/1/17.
//  Copyright © 2017 Universidad de Alicante. All rights reserved.
//

import Foundation
import CoreData


extension Nota {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Nota> {
        return NSFetchRequest<Nota>(entityName: "Nota");
    }

    @NSManaged public var fecha: Date?
    @NSManaged public var texto: String?

}
