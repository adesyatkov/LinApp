//
//  TableViewController.swift
//  LinApp
//
//  Created by Anton on 25.03.18.
//  Copyright © 2018 Anton. All rights reserved.
//

import UIKit
import Firebase

class TableViewController: UITableViewController {

    var aktien = [Aktien]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadKategorie()
        

        
    }
    
    func loadKategorie(){
        
        Database.database().reference().child("Kategorien").child("Aktien").observe(.childAdded, with: { (snapshot) in
           
           // if let dictionary = snapshot.value as? [String: AnyObject]{
                
            let dictionary = snapshot.value as? [String: String]
            
            print (type(of: dictionary ))
                let kategorie = Aktien()
                
            kategorie.wort = dictionary?["wort"]
            kategorie.Beschreibung = dictionary?["Beschreibung"]
            kategorie.Synonym = dictionary?["Synonym"]
                
//            kategorie.setValuesForKeys(dictionary!)
          
            
            self.aktien.append(kategorie)
            
            self.tableView.reloadData()
        
    
            
            print(snapshot)
        }, withCancel: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return aktien.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MerklisteTableViewCell
        
        let aktie = aktien[indexPath.row]
        
        cell.WordLabel.text = aktie.wort
        
        return cell
    }

   
}
