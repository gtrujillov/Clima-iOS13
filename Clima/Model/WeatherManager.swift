//
//  weatherManager.swift
//  Clima
//
//  Created by gonzalo trujillo vallejo on 9/1/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation


protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager : WeatherManager,  weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{
    
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=57b39d36639c80c2aaf02df0f374e8b6&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitute: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitute)"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
        // Crea una URL desde el string proporcionado
        if let url = URL(string: urlString) {
            // Crea una sesión por defecto
            let session = URLSession(configuration: .default)
            // Crea una tarea de datos con la sesión, pasando la URL y un manejador de completado
            let task = session.dataTask(with: url) { (data, response, error) in
                // Verifica si hay errores
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                // Asegurando de que los datos no son nulos
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            // Inicia la tarea
            task.resume()
        }
    }
    
    
    func parseJSON(_ weatherData: Data)-> WeatherModel? {
        
        let decoder = JSONDecoder()
        
        do {
            
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}






