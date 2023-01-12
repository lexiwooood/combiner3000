//
//  ContentView.swift
//  Food Combiner 3000
//
//  Created by Lexi Wood on 1/11/23.
//

import SwiftUI
import Foundation

struct ContentView: View {
    struct FoodInfo: Codable {
        let description: String
        let fdcId: Int
        let foodNutrients: [FoodNutrient]
        let publicationDate: String
        let brandOwner: String?
        let gtinUpc: String?
        let ndbNumber: Int?
        let foodCode: String?
        let name: String?
        
        enum CodingKeys: String, CodingKey {
            case description, fdcId, foodNutrients, publicationDate
            case brandOwner, gtinUpc, ndbNumber, foodCode, name
        }
    }
    
    struct FoodNutrient: Codable {
        let number: String?
        let name: String?
        let amount: Double?
        let unitName: String?
        let derivationCode: String?
        let derivationDescription: String?
    }
    
    @State private var foodListText: String = ""
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
                    let proteinFoods: [FoodInfo] = self.foodInfoList.compactMap { foodInfo in
                        guard let foodNutrients = foodInfo?.foodNutrients else { return nil }
                        for nutrient in foodNutrients {
                            if nutrient.name == "Protein" {
                                return foodInfo
                            }
                        }
                        return nil
                    }
                    
                    let nonProteinFoods: [FoodInfo] = self.foodInfoList.compactMap { foodInfo in
                        guard let foodNutrients = foodInfo?.foodNutrients else { return nil }
                        for nutrient in foodNutrients {
                            if nutrient.name != "Protein" {
                                return foodInfo
                            }
                        }
                        return nil
                    }
                }
    //variables needed for api call
    struct Food: Decodable {
        let fdcId: Int?
        // other properties
    }
    
    struct SearchResult: Decodable {
        let foods: [Food]
        struct Food: Decodable {
            let fdcId: Int
        }
    }
    
    func fetchFoodInfo(foodName: String, completion: @escaping (FoodInfo?) -> Void) {
        let apiKey = "oyAsqdDwRsGdCNGeRZaZnp10zzBAJSwA4wjy1ZdW"
        let searchURL = URL(string: "https://api.nal.usda.gov/fdc/v1/search?api_key=\(apiKey)&query=\(foodName)")!
        
        URLSession.shared.dataTask(with: searchURL) { (data, response, error) in
            if let error = error {
                print("Error searching for food: \(error)")
                completion(nil)
                return
            }
            guard let data = data
            else {
                print("No data received")
                completion(nil)
                return
            }
            do {
                let searchResult = try? JSONDecoder().decode(SearchResult.self, from: data)
                if let foodId = searchResult?.foods.first?.fdcId {
                    let foodURL = URL(string: "https://api.nal.usda.gov/fdc/v1/\(foodId)?api_key=\(apiKey)")!
                    URLSession.shared.dataTask(with: foodURL) { (data, response, error) in
                        if let error = error {
                            print("Error fetching food details: \(error)")
                            completion(nil)
                            return
                        }
                        guard let data = data else {
                            print("No data received")
                            completion(nil)
                            return
                        }
                        print(String(data: data, encoding: .utf8)!)
                        do {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let foodInfo = try decoder.decode(FoodInfo.self, from: data)
                            completion(foodInfo)
                            print(response)
                        } catch {
                            print("Error decoding JSON: \(error)")
                            completion(nil)
                        }
                    }.resume()
                } else {
                    print("No food found")
                    completion(nil)
                }
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }
                    }

        }
    }
}
