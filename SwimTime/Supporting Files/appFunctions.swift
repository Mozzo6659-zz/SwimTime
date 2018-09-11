//
//  appFunctions.swift
//  SwimTime
//
//  Created by Mick Mossman on 3/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation
import UIKit
class appFunctions {
    
    //MARK: - Photo Functions
    func makePhotoName(memberid:Int) -> String {
    
        return ("\(memberid).jpg")
    
    
    }
    
    func writePhoto(memberid:Int, img:UIImage) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            
            let photoName = makePhotoName(memberid: memberid)
            
            
            let fileURL = dir.appendingPathComponent(photoName)
            
            
            let data = UIImageJPEGRepresentation(img, 1.0)
            
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
        
        if let date = dateFormatter.date(from:dttocheck) {
            
            isOk = true
        }
        
    
        return isOk;
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
    
}
