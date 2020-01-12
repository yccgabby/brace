//
//  MedicalFilesLoad.swift
//  BraceApp
//
//  Created by Gabby Chan and Ayla Orucevic on 2020-01-11.
//  Copyright © 2020 Brace Inc. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

struct MedicalFile: Codable {
    let firstName:String
    let lastName:String
    let dayOfVisit:String
    let monthOfVisit:String
    let yearOfVisit:String
    let visitWithWhom:String
    let locationOfVisit:String
    let comment:String
}

// Ideally, you would want to import a JSON file sent through RFID tag; for the purpose of the demo
// a single medical file was included, but in the future, it should contain the patient's entire medical history
let json = """
{
          "firstName": "First Name: Mary",
          "lastName": "Last Name: Poppins",
          "dayOfVisit": "Day of Visit: 6",
          "monthOfVisit": "Month of Visit: January",
          "yearOfVisit": "Year of Visit: 2020",
          "visitWithWhom": "Physician: Dr. John Doe",
          "locationOfVisit": "Address: 123 Sesame St",
          "comment": "Notes: High blood pressure"
}
""".data(using: .utf8)!

class MedicalFilesLoad {
    var firstName:String = ""
    var lastName:String = ""
    var dayOfVisit:String = ""
    var monthOfVisit:String = ""
    var yearOfVisit:String = ""
    var visitWithWhom:String = ""
    var locationOfVisit:String = ""
    var comment:String = ""
    var profile : [String] = []
    
    init () {
        loadDataFromMedicalFiles()
        profile = [firstName, lastName, dayOfVisit, monthOfVisit, yearOfVisit, visitWithWhom, locationOfVisit, comment]
    }
        
    func loadDataFromMedicalFiles() {
        let decoder = JSONDecoder() // turn JSON object into Swift object
        let medicalFile = try! decoder.decode (MedicalFile.self, from: json)
        firstName = medicalFile.firstName
        lastName = medicalFile.lastName
        dayOfVisit = medicalFile.dayOfVisit
        monthOfVisit = medicalFile.monthOfVisit
        yearOfVisit = medicalFile.yearOfVisit
        visitWithWhom = medicalFile.visitWithWhom
        locationOfVisit = medicalFile.locationOfVisit
        comment = medicalFile.comment
    }
    
    @objc func twilioNotification() { // sends notification to trusted contact member of patient whose medical record is being accessed
        let group = DispatchGroup() // initialize
        if let accountSID = ProcessInfo.processInfo.environment["TWILIO_ACCOUNT_SID"], // needs to be configured locally
        let authToken = ProcessInfo.processInfo.environment["TWILIO_AUTH_TOKEN"] {
            group.enter()
          let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages"
          let parameters = ["From": "+16474929885", "To": "+12263382265", "Body": "Good morning, Baby Yoda.\nDr. John Doe has just accessed Mary's medical information.\nIt was accessed at 12/01/2020 at 4:52am.\nPlease contact Dr. John Doe at +14161234567 for any comments or concerns regarding this data access.\nHave a great rest of your day! "] // sample message 
            
          Alamofire.request(url, method: .post, parameters: parameters)
            .authenticate(user: accountSID, password: authToken)
            .responseJSON { response in
              debugPrint(response)
          }

          RunLoop.main.run()
            group.leave()
        }
    }
}
