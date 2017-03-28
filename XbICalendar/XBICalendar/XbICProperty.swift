//
//  XbICProperty.swift
//  XbICalendar
//
//  Created by Tikitu de Jager on 28/03/17.
//  Copyright © 2017 GaltSoft. All rights reserved.
//

import Foundation

extension XbICProperty {
    func components(from value: OpaquePointer, parameters: [String: Any]) -> DateComponents {
        let t = icalvalue_get_datetime(value)
        var components = DateComponents(year: Int(t.year), month: Int(t.month), day: Int(t.day),
                                        hour: Int(t.hour), minute: Int(t.minute), second: Int(t.second))

        if t.is_utc != 0 {
            components.timeZone = TimeZone(secondsFromGMT: 0)
        } else {
            if let tzid = parameters["TZID"] as? String {
                components.timeZone = TimeZone(identifier: tzid)
            } else {
                components.timeZone = TimeZone(secondsFromGMT: 0)
            }
        }
        return components
    }
    
    public func datetimeFromValue(_ value: OpaquePointer, parameters: [String: Any]) -> Date? {
        let calendar = NSCalendar.current
        let components = self.components(from: value, parameters: parameters)
        // t.is_daylight
        // t.is_date
        return calendar.date(from: components)
    }
}
