//
//  ExerciseChartView.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/14/24.
//

import Charts
import SwiftUI

struct ExerciseChartView: View {

    var exerciseSets: [ExerciseSet]
    
    var body: some View {
        Chart {
            ForEach(exerciseSets) { set in
                BarMark(
                    x: .value("Date", set.date, unit: .day),
                    y: .value("Weight", set.weight)
                )
            }
            .foregroundStyle(.blue)
        }
        .padding( 8)
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: 3600 * 24 * 30)
        .chartScrollTargetBehavior(
          .valueAligned(
            matching: DateComponents(hour: 0),
            majorAlignment: .matching(DateComponents(day: 1))))
        .chartXAxis {
            AxisMarks(values: .stride(by: .month, count: 1)) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(), collisionResolution: AxisValueLabelCollisionResolution.disabled)
                    .offset(y: 12)
            }
            AxisMarks(values: .stride(by: .day, count: 7)) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day())
            }
        }
        
    }
    
}
