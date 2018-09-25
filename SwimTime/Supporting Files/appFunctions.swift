//
//  appFunctions.swift
//  SwimTime
//
//  Created by Mick Mossman on 3/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class appFunctions {
    
    let realm = try! Realm()
    
    //MARK: - Photo Functions
    func makePhotoName(memberid:Int) -> String {
    
        return ("\(memberid).jpg")
    
    
    }
    
    func writePhoto(memberid:Int, img:UIImage) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            
            let photoName = makePhotoName(memberid: memberid)
            
            
            let fileURL = dir.appendingPathComponent(photoName)
            
            
            let data = img.jpegData(compressionQuality: 1.0)
            
           // print(fileURL.absoluteString)
            
            //print(getFullPhotoPath(memberid: memberid))
            
            do {
                try data?.write(to: fileURL)
            }catch{
                print("couldnt write to fle")
            }
        }
    }
    func getFullPhotoPath(memberid:Int) -> String {
       
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + makePhotoName(memberid: memberid)
        
        
    
    }
    
    func getGlobalDateFormat() -> String {
        return "dd/MM/yyyy"
    }
    
    func formatDate(thedate:Date, theformat:String = "") -> String {
        var myFormat = getGlobalDateFormat()
        if !theformat.isEmpty {
            myFormat = theformat
        }
        let dtf = DateFormatter()
        dtf.dateFormat = myFormat
        return dtf.string(from: thedate)
    }
    //MARK: - Time Functions
    func adjustOnekSecondsForDistance(distance:Int,timeinSeconds:Int) -> Int {
        
        let divBy:Double = Double(distance) / 1000.00
        //var result: Double = Double(textfield) * VAT
        
        return Int(Double(timeinSeconds) * divBy)
        
    }
    
    func convertSecondsToTime(timeinseconds:Int) -> String{
        
       
        
        let hours = Int(abs(timeinseconds) / 3600)
    
        let seconds = Int(abs(timeinseconds)  % 60)
        let  minutes = Int((abs(timeinseconds) / 60) % 60)
   
        return String(format: "%02d:%02d:%02d",hours, minutes, seconds)
        
    
    }

    func validateMinutesSeconds(howmany:Int) -> String {
        var errmsg = ""
        
        if (howmany > 59 || howmany < 0) {
            errmsg = "Invalid time format"
        }
        
        
        return errmsg
    }

    func findTimeDiffInSeconds(startDate:Date) -> Int {
        
        let components = Calendar.current.dateComponents([.second], from: startDate, to: Date())
        
        return components.second!
        
    }
    
    func convertTimeToSeconds(thetimeClock:String) -> Int {
        let thetime = thetimeClock.components(separatedBy: ":")
    
        let theSeconds = (Int(thetime[0])! * 3600) + (Int(thetime[1])! * 60) + Int(thetime[2])!
    
        return theSeconds
    }

    func isValidDate(theday:Int, themonth:Int, theyear:Int) -> Bool {
        var isOk = false
    
        let dttocheck = String(format:"%04d-%02d-%02d",theyear,themonth,theday)
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let _ = dateFormatter.date(from:dttocheck) {
            
            isOk = true
        }
        
    
        return isOk;
    }

    func getAgeFromDate(fromDate:Date,toDate:Date) -> Int {
        let calendar = NSCalendar.current
        
        let components = Set<Calendar.Component>([.year])
         let datecomp = calendar.dateComponents(components, from: fromDate, to: toDate)
        
        return datecomp.year ?? 0
        
        
    }
    func getDateDiffSeconds(fromDate:Date) -> Int {
        let calendar = NSCalendar.current
        
        let components = Set<Calendar.Component>([.second, .minute, .hour])
        
        //let datecomp = calendar.component(components, from: fromDate)
        //let comp = calendar.c
        //let components = calendar.dateComponents([.second], from: fromDate, to: toDate)
        let datecomp = calendar.dateComponents(components, from: fromDate, to: Date())
        
        return (datecomp.hour! * 3600) + (datecomp.minute! * 60) + (datecomp.second)!
        
    }
    
    func getDateDiffHours(fromDate:Date) -> Int {
        let calendar = NSCalendar.current
       
        let hour = calendar.component(.hour, from: fromDate)
        //let comp = calendar.c
        //let components = calendar.dateComponents([.hour], from: fromDate, to: toDate)
        
        //return components.hour!
        return hour
    }
    func isDuplicateClub(newClubname: String) -> Bool {
        let myarray = realm.objects(SwimClub.self)
        
        if let _  = myarray.index(where: {$0.clubName == newClubname}) {
            return true
        }else{
            return false
        }
        
    }
}
