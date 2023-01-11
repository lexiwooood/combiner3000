//
//  ContentView.swift
//  Food Combiner 3000
//
//  Created by Lexi Wood on 1/11/23.
//

import SwiftUI
import Foundation

struct ContentView: View {
    struct FoodInfo: Decodable {
        // properties of FoodInfo
    }

    @State private var foodListText: String = ""
    @State private var orderedFoodList: [String] = []
    @State private var foodInfoList: [FoodInfo?] = []

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
                    fetchFoodInfo(foodName: food) { foodInfo in
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
    //api call
    func fetchFoodInfo(foodName: String, completion: @escaping (FoodInfo?) -> Void) {
        let apiKey = "YOUR_API_KEY"
        let url = URL(string: "https://api.nal.usda.gov/fdc/v1/food/\(foodName)?api_key=\(apiKey)")!

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            do {
                let foodInfo = try JSONDecoder().decode(FoodInfo.self, from: data)
                completion(foodInfo)
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
}

