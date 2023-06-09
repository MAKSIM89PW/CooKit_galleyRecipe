//
//  FavoriteRecipeModel.swift
//  galleyRecipe
//
//  Created by Камиль Хакимов on 27.02.2023.
//

import UIKit
import RealmSwift

class RealmFavoriteRecipe: Object {
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var readyInMinutes = 0
    @objc dynamic var servings = 0
    @objc dynamic var image = ""
    var ingredients = List<RealmIngredients>()
    var instruction = List<RealmInstruction>()

    @objc dynamic var status = false

    override static func primaryKey() -> String? {
            return "id"
        }
}

class RealmIngredients: Object {
    @objc dynamic var originalName = ""
    @objc dynamic var measures: RealmMeasures!
}

class RealmMeasures: Object {
    @objc dynamic var metric: RealmMetric!
}

class RealmMetric: Object {
    @objc dynamic var amount = 0.0
    @objc dynamic var unitShort = ""
}

class RealmInstruction: Object {
    var realmSteps = List<RealmStep>()
}

class RealmStep: Object {
    @objc dynamic var number = 0
    @objc dynamic var step = ""
}
