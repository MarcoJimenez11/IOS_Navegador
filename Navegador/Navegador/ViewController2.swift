//
//  ViewController2.swift
//  Navegador
//
//  Created by mapple on 15/01/2019.
//  Copyright © 2019 mapple. All rights reserved.
//

import UIKit
import SQLite3

class ViewController2: UIViewController {

    @IBOutlet weak var textview: UITextView!
    var historial = [String]()
    var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let h = [String](historial)
        textview.isEditable = false;
        for i in h{
            textview.text = textview.text + i + "\n"
        }
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Navegadordb.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error abriendo base de datos")
        }
    }
    
    @IBAction func borrar(_ sender: Any) {
        var stmt: OpaquePointer?
        
        let queryString = "DELETE FROM HISTORIAL"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            
            print("error al borrar: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error al borrar: \(errmsg)")
            return
        }
        textview.text = " "
    }
    
    @IBAction func volver(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
