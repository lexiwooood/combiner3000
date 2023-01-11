//
//  ContentView.swift
//  Food Combiner 3000
//
//  Created by Lexi Wood on 1/11/23.
//

import SwiftUI
import Foundation

import FoodApi

struct ContentView: View {

    @State private var foodListText: String = ""
    @State private var orderedFoodList: [String] = []

    var body: some View {
        VStack {
            TextField("Enter food list, separated by ','", text: $foodListText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Order Foods") {
                let foodList = self.foodListText.split(separator: ",").map(String.init)

                let group = DispatchGroup()
                for food in foodList {
                    group.enter()
                    let foodApi = FoodApi()
                    foodApi.fetchFoodInfo(foodName: food) { foodInfo in
                        if let foodInfo = foodInfo {
                            self.foodInfoList.append(foodInfo)
                        }
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    // here you can use the foodInfoList and foodList to sort the foods.
                    self.orderedFoodList = self.foodListText.split(separator: ",").map(String.init).sorted()
                    // reload your tableView or update your UI
                }

            }.padding()

            List(self.orderedFoodList, id: \.self) { food in
                Text(food)
            }
        }
    }
}

