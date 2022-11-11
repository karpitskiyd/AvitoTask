//
//  ViewController.swift
//  AvitoTask
//
//  Created by Даниил Карпитский on 11/8/22.
//

import UIKit

class AvitoGuysViewController: UIViewController, UITableViewDataSource {
    
    private var employeesArray = [Employee]()
    private let reachability = try! Reachability()
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupReachability()
        getData()
        setupTableView()
    }

    
    @objc private func refreshList(_ sender: Any) {
        getData()
    }
    
    private func getData() {
        if userDefaultsExists(key: "employees") {
            let data = getDataFromUserDefaults(key: "employees")
            let time = getTimeInDateFormat(stringDate: data.time!)
            let interval = abs(time!.timeIntervalSinceNow/60)
            updateRefreshBar(interval: interval)

            if interval < 60 {
                print("data updated \(Int(interval)) mins ago")
                self.employeesArray = data.array
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            else {
                print("data updated")
                resetDefaults()
                sendRequest()
            }
        }
        else {
            sendRequest()
        }
        refreshControl.endRefreshing()
    }
    
    private func sendRequest() {
        let url = URL(string: "https://run.mocky.io/v3/1d1cb4ec-73db-4762-8c4b-0b8aa3cecd4c")!
        URLSession.shared.dataTask(with: url) { [self]
            
            (data, response, error) in
            
            guard let data = data else {
                print(error.debugDescription)
                return
            }
            
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            
            do {
                let requestData = try? JSONDecoder().decode(RequestData.self, from: data)
                let array = requestData?.company.employees
                employeesArray = filterArray(array: array ?? [])
                let savedData = SavedData(time: getActualTimeInString(), array: employeesArray)
                saveDataToUserDefaults(array: savedData)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }.resume()
    }

    private func setupTableView() {
        let customCell = UINib(nibName: "AvitoGuysTableViewCell",
                               bundle: nil)
        tableView.register(customCell,
                           forCellReuseIdentifier: "AvitoGuysTableViewCell")
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshList(_:)), for: .valueChanged)
        tableView.dataSource = self
        tableView.rowHeight = 75
        tableView.separatorStyle = .none
        
    }
    
    private func updateRefreshBar(interval: Double) {

        let font = UIFont.systemFont(ofSize: 12)
        let attributes = [NSAttributedString.Key.font: font]
        if interval < 1 {
            let secondsInterval = Int(interval*60)
            refreshControl.attributedTitle = NSAttributedString(string:
                                                                    "Last update was \(secondsInterval) seconds ago 👻" ,
                                                                attributes: attributes)
        } else {
        refreshControl.attributedTitle = NSAttributedString(string:
                                                                "Last update was \(Int(interval)) minutes ago 👻" ,
                                                            attributes: attributes)
        }
    }

    private func filterArray(array:[Employee]) -> [Employee] {
        let filteredArray = array.sorted(by: { (firstName, secondName) -> Bool in
            let sortedFirstName = firstName.name
            let sortedSecondName = secondName.name
            return (sortedFirstName.localizedCaseInsensitiveCompare(sortedSecondName) == .orderedAscending)
        })
        return filteredArray
    }
    
    private func getTimeInDateFormat(stringDate: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+3")
        return dateFormatter.date(from: stringDate)
    }
    
    private func getActualTimeInString() -> String {
        let dateNow = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let dateNowString = dateFormatter.string(from: dateNow)
        
        return dateNowString
    }
    
    private func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    private func userDefaultsExists(key: String) -> Bool {
        guard let _ = UserDefaults.standard.object(forKey: key) else { return false }
        return true
    }
    
    
    private func saveDataToUserDefaults(array: SavedData) {
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(array)
            UserDefaults.standard.set(data, forKey: "employees")
        } catch {
            print(error)
        }
    }
    
    private func getDataFromUserDefaults(key: String) -> SavedData {
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                let dataToDecode = try decoder.decode(SavedData.self, from: data)
                return dataToDecode
                
            } catch {
                let defaultValue = SavedData(time: nil, array: [])
                return defaultValue
            }
        }
        else {
            let defaultValue = SavedData(time: nil, array: [])
            return defaultValue
        }
    }
    
    private func setupReachability() {
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via wifi")
            }else{
                print("Reachable via cellular")
            }
            
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            self.showAlert()
        }
        do{
            try reachability.startNotifier()
        }catch{
            print("unable to start notifier")
        }
    }
    
    func showAlert(){
        
        let alert = UIAlertController(title: "no Internet", message: "This App Requires internet connection!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: {_ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension AvitoGuysViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AvitoGuysTableViewCell") as? AvitoGuysTableViewCell {
            cell.setupCell(model: employeesArray[indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employeesArray.count
    }
    
}

