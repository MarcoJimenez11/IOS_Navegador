//
//  ViewController.swift
//  Navegador
//
//  Created by mapple on 14/01/2019.
//  Copyright © 2019 mapple. All rights reserved.
//

import UIKit
import WebKit
import SQLite3

class ViewController: UIViewController {
    
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var url: UITextField!
    var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Navegadordb.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        else {
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS HISTORIAL (id INTEGER PRIMARY KEY AUTOINCREMENT, url TEXT)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
            }
        }
    }


    @IBAction func forward(_ sender: Any) {
        webview.goForward()
    }
    
    
    
    @IBAction func back(_ sender: Any) {
        webview.goBack()
    }
    
    @IBAction func search(_ sender: Any) {
        
        if url.text != "" {
            if (url.text?.characters.count)! > 7 {
                let index1 = url.text?.index((url.text?.startIndex)!, offsetBy: 7)
                
                let substring1 = url.text?.substring(to: index1!)
                if substring1?.uppercased() != "HTTP://" {
                    url.text = "http://"+url.text!
                }
            }
            else {
                url.text = "http://"+url.text!
            }
            if (url.text?.characters.count)! > 4 {
                let index1 = url.text?.index((url.text?.endIndex)!, offsetBy: -4)
                
                let substring1 = url.text?.substring(from: index1!)
                if substring1?.uppercased() != ".COM" {
                    url.text = url.text! + ".com"
                }
            }
        }
        url.text = url.text?.replacingOccurrences(of: " ", with: "")
        
        webview.load(URLRequest(url: URL(string: url.text!)!))
        
        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO HISTORIAL ('url') VALUES ('"+url.text!+"')"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparando insert: \(errmsg)")
            return
        }
        
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error al insertar: \(errmsg)")
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let historialdb = getHistorial()
        
        if segue.identifier == "dos" {
            if let viewDos = segue.destination as? ViewController2 {
                viewDos.historial = historialdb
            }
        }
    }
    
    func getHistorial()->[String]{
        let queryString = "SELECT * FROM HISTORIAL"
        var historialdb = [String]()
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error al preparar select: \(errmsg)")
            return [""]
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            if(sqlite3_column_text(stmt, 1) != nil){
                let nombre = String(cString: sqlite3_column_text(stmt, 1))
                historialdb.append(nombre)
            }
        }
        
        return historialdb
    }
    
}

