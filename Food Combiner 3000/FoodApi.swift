//
//  FoodApi.swift
//  Food Combiner 3000
//
//  Created by Lexi Wood on 1/11/23.
//

import Foundation

class FoodApi {
    struct FoodInfo: Codable {
        // properties of FoodInfo
    }
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

