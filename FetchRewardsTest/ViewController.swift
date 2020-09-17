//
//  ViewController.swift
//  FetchRewardsTest
//
//  Created by Saranya Kalyanasundaram on 9/16/20.
//  Copyright © 2020 Saranya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let urlString = "https://fetch-hiring.s3.amazonaws.com/hiring.json"
    private var itemList = [Item]()
    private var listSections  = [List]()
    
    @IBOutlet weak var ItemsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load json data from given url string
        self.loadJson(fromURLString: urlString) { (result) in
            switch result {
            case .success(let data):
                //parse the recieved json data
                self.parse(jsonData: data)
            case .failure(let error):
                //alert the user error fetching data
                self.showAlert(message : error.localizedDescription)
            }
        }
    }
    
    
    private func loadJson(fromURLString urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        //Create a URL from given url string
        if let url = URL(string: urlString) {
            
            //Create a URLSession
            let urlSession = URLSession(configuration: .default)
            
            //Create a dataTask
            let dataTask = urlSession.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                if let data = data {
                    completion(.success(data))
                }
            }
            //start the dataTask
            dataTask.resume()
        }
    }
    
    private func parse(jsonData: Data) {
       
        do {
            let decodedData = try JSONDecoder().decode([Item].self,
                                                       from: jsonData)
            //processData with the decoded json data
            processData(with : decodedData)
            
        } catch {
            showAlert(message: error.localizedDescription)
        }
    }
    
    private func processData(with data: [Item]){
        
        //filter all the null and empty string named items
        let itemsListWithNames = data.filter { ![nil, ""].contains($0.name) }
        
        //create the array of list section 
        listSections = List.group(items: itemsListWithNames)
        
        //update the data in the table view inside the main queue
        DispatchQueue.main.async {
            self.ItemsTableView.reloadData()
        }
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}
//MARK: - UITableViewDataSource protocol methods

extension ViewController : UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return listSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return "List No: \(listSections[section].id)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let list = listSections[section].items
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let section = self.listSections[indexPath.section]
        let item = section.items[indexPath.row]
        cell.textLabel?.text = "Name : \(item.name ?? "")"
        cell.detailTextLabel?.text = "Product Id : \(String(item.id))"
        return cell
    }
    
    
}
