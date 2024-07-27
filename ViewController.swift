//
//  ViewController.swift
//  Lab3
//
//  Created by Parth Tilva on 2024-03-14.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate{
    
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var weatherConditionImage: UIImageView!
    
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var celToFahr: UISwitch!
    
    private let locationManager = CLLocationManager()
//    private let locationManagerDeligate = MyLocationManagerDelegate()
    
    var weather: Weather?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        // Do any additional setup after loading the view.
        displayImageForDemo()
        
        locationManager.delegate = self
        
    }
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        searchBtn()
        return true
    }
    private func displayImageForDemo(){
        
        let config = UIImage.SymbolConfiguration(paletteColors: [
            .systemYellow, .systemOrange, .systemYellow
        ])
        weatherConditionImage.preferredSymbolConfiguration = config
        weatherConditionImage.image = UIImage (systemName: "sunrise.fill")
    }
    private func searchBtn(){
        guard let searchQuery = searchTextField.text, !searchQuery.isEmpty else {
            return
        }
        loadWeather(search: searchQuery)
    }
    


    @IBAction func onLocationTapped(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        loadWeather(search: searchTextField.text)
        searchTextField.resignFirstResponder()
    }
    
    @IBAction func switchbutton(_ sender: UISwitch) {
        if sender.isOn {
            if let weather = weather {
                            temperatureLabel.text = "\(weather.temp_f)°F"
                        }
        } else {
            if let weather = weather {
                            temperatureLabel.text = "\(weather.temp_c)°C"
                        }
        }
    }
    private func updateTempLabel(){
        if let weather = weather {
            if celToFahr.isOn{
                temperatureLabel.text="\(weather.temp_f)F"
            }else{
                temperatureLabel.text = "\(weather.temp_c)C"
            }
        }
    }
    private func loadWeather(search: String?){
        guard let search = search else{
            return
        }
        guard let url = getURL(query: search) else {
            print("could not get URL")
            return
        }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { data, response, error in
            print("Network call complete")
            guard error == nil else{
                print("Received error")
                return
            }
            guard let data = data else{
                print("No data found")
                return
            }
            
            if let weatherResponse = self.parseJson(data: data){
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                self.weather = weatherResponse.current
                
                DispatchQueue.main.async{
                    self.locationLabel.text = weatherResponse.location.name
                    self.temperatureLabel.text = "\(weatherResponse.current.temp_c)C"
                }
                
            }
        }
        dataTask.resume()
    }
    
    private func getURL(query: String) -> URL?{
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndPoint = "current.json"
        let apiKey = "b2662efc8d864502a3035618241503"
        guard let url = "\(baseUrl)\(currentEndPoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string:url)
    }
    private func parseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
        }catch{
            print("Error Decoding")
        }
        
        return weather
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got Location!")
        
        if let location = locations.last{
            
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let query = "\(latitude),\(longitude)"
            loadWeather(search: query)
            print("\(latitude),\(longitude)")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
struct WeatherResponse: Decodable{
    let location: Location
    let current: Weather
}
struct Location: Decodable{
    let name:String
}
struct Weather: Decodable{
    let temp_c:Float
    let temp_f:Float
    let condition: WeatherCondition
}
struct WeatherCondition: Decodable{
    let text:String
    let code:Int
}

