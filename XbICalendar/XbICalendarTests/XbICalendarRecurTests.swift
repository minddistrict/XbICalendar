//
//  File.swift
//  XbICalendar
//
//  Created by Andrew Halls on 10/1/14.
//  Copyright (c) 2014 GaltSoft. All rights reserved.
//
import UIKit
import XCTest

class XbICalendarRecurTestsSwift: XbICalendarIcsTest {

  override func icsFileNameUnderTest() -> String! {
    return "recur"
  }

 func test_initialization() {
  XCTAssertNotNil(self.rootComponent, "Initialization");
  XCTAssertEqual(self.calendars.count, 1, "Expected 1 calendar");
  }

    func test_rrule_output_across_DST_transition() {
      let first: icaltimetype, second: icaltimetype
        (first, second) = {
          let todo = component(at: 0, kind: ICAL_VTODO_COMPONENT, ofCalendarAt: 0)!
          let dtStart = todo.firstProperty(of: ICAL_DTSTART_PROPERTY)!.icalBuild()
          let rrule = todo.firstProperty(of: ICAL_RRULE_PROPERTY)!.icalBuild()
          let iter = icalrecur_iterator_new(icalproperty_get_rrule(rrule), icalproperty_get_dtstart(dtStart))
          defer {
              icalrecur_iterator_free(iter)
          }
          let first: icaltimetype = icalrecur_iterator_next(iter)
          let second: icaltimetype = icalrecur_iterator_next(iter)
          return (icaltime_convert_to_zone(first, icaltimezone_get_utc_timezone()),
                  icaltime_convert_to_zone(second, icaltimezone_get_utc_timezone()))
      }()

        XCTAssertEqual(first.zone, second.zone)
        XCTAssertEqual(first.is_utc, 1)
        XCTAssertEqual(first.day + 1, second.day)
        XCTAssertEqual(first.hour - 1, second.hour) // DST transition shifts "9 o'clock"
    }

    func test_ical_to_xb_to_ical_round_trip_preserves_dtstart_property_data() {
        // This test shows the root cause of the bug exposed in test_rrule_output_across_DST_transition
        // The timezone information is lost somewhere in the round trip, moving the UTC-normalised moment by an hour 
        let inProperty = icalproperty_new_from_string("DTSTART;TZID=Europe/Amsterdam;VALUE=DATE-TIME:20160326T090000".cString(using: .utf8))
        let xbProperty = XbICProperty(icalProperty: inProperty)!
        let outProperty = xbProperty.icalBuild()

        let utcIn = icaltime_convert_to_zone(icalproperty_get_dtstart(inProperty), icaltimezone_get_utc_timezone())
        let utcOut = icaltime_convert_to_zone(icalproperty_get_dtstart(outProperty), icaltimezone_get_utc_timezone())
        assertEqual(utcIn, utcOut)
    }
}

func assertEqual(_ left: icaltimetype, _ right: icaltimetype) {
    XCTAssertEqual(left.year, right.year)
    XCTAssertEqual(left.month, right.month)
    XCTAssertEqual(left.day, right.day)
    XCTAssertEqual(left.hour, right.hour)
    XCTAssertEqual(left.minute, right.minute)
    XCTAssertEqual(left.second, right.second)
    XCTAssertEqual(left.is_date, right.is_date)
    XCTAssertEqual(left.is_daylight, right.is_daylight)
    XCTAssertEqual(left.is_utc, right.is_utc)
    XCTAssertEqual(left.zone, right.zone)
}
