//
//  addDelegate.swift
//  Techo$
//
//  Created by Yue Yan on 4/5/2022.
//

import Foundation

protocol AddCategoryDelegate{
    func addCategory(category: Category)
}

protocol AddAccountDelegate{
    func addAccount(account: Account)
}

protocol AddEventDelegate{
    func addEvent(event: Event)
}

protocol AddGoalDelegate{
    func addGoal(goal: Goal)
}

protocol AddLocationDelegate{
    func addLocation(location: LocationAnnotation)
}

protocol TransactionFunctionDelegate{
    func filterSegue()
}
