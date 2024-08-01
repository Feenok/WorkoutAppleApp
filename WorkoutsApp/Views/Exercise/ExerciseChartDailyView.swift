//
//  ExerciseChartDailyView.swift
//  WorkoutsApp
//
//  Created by Ernest Margariti on 7/31/24.
//

import Charts
import SwiftUI

struct ExerciseChartDailyView: View {
    @Environment(\.calendar) var calendar
    
    var vm: ExerciseDetailsViewModel
    var sets: [Date:[ExerciseSet]]
    
    var sortByWeight: Bool
    var sortByReps: Bool
    var sortByTime: Bool
    
    var selectedDate: Date?
    
    @State private var selectedSetIndex: Int?
    
    var selectedSets: [ExerciseSet]? {
        guard let selectedDate = selectedDate else { return nil }
        return sets[selectedDate]
    }
    
    var body: some View {
        
        let maxWeight = selectedSets?.max(by: { $0.weight < $1.weight })?.weight ?? 0
        let maxReps = selectedSets?.max(by: { $0.reps < $1.reps })?.reps ?? 0
        let maxDuration = selectedSets?.compactMap { $0.duration }.max() ?? 0
        
        var yAxisMax: Double {
            if sortByWeight {
                return Double(maxWeight) * 1.45
            } else if sortByReps {
                return Double(maxReps) * 1.45
            } else if sortByTime {
                return Double(maxDuration) * 1.45
            }
            return 0.0
        }
        let mostRecentDate = sets.keys.max() ?? Date()
        HStack {
                if sortByWeight {
                    Text("Weight (LBS)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .rotationEffect(Angle(degrees: -90))
                        .fixedSize()
                        .frame(width: 15)
                        .padding(.top, -15)
                        .padding(.trailing, -15)
                } else if sortByReps {
                    Text("Reps")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .rotationEffect(Angle(degrees: -90))
                        .fixedSize()
                        .frame(width: 15)
                        .padding(.top, -20)
                        .padding(.trailing, -15)
                } else if sortByTime {
                    Text("Duration (Sec)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .rotationEffect(Angle(degrees: -90))
                        .fixedSize()
                        .frame(width: 15)
                        .padding(.top, -20)
                        .padding(.trailing, -15)
                }
            VStack {
                
                if sortByWeight {
                    Text("Weight per Set - \(selectedDate!, format: .dateTime.year().month().day())")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.gray)
                        .fixedSize()
                        .frame(width: 15)
                        //.padding(.leading, -15)
                        .padding(.vertical, -10)
                } else if sortByReps {
                    Text("Reps per Set")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.gray)
                        .fixedSize()
                        .frame(width: 15)
                        //.padding(.leading, -15)
                        .padding(.vertical, -10)
                } else if sortByTime {
                    Text("Duration per Set")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.gray)
                        .fixedSize()
                        .frame(width: 15)
                        //.padding(.leading, -15)
                        .padding(.vertical, -10)
                }
                
                Chart {
                    if let selectedSets = selectedSets {
                        ForEach(Array(selectedSets.enumerated()), id: \.element) { index, set in
                            if sortByWeight && !sortByReps && !sortByTime {
                                BarMark(
                                    x: .value("Set", index+1),
                                    y: .value("Weight", set.weight)
                                )
                            }
                            else if !sortByWeight && sortByReps && !sortByTime {
                                BarMark(
                                    x: .value("Set", index+1),
                                    y: .value("Reps", set.reps)
                                )
                            } else if !sortByWeight && !sortByReps && sortByTime {
                                BarMark(
                                    x: .value("Set", index+1),
                                    y: .value("Duration", set.duration ?? 0)
                                )
                            }
                        }
                        .foregroundStyle(.blue)
                    }
                    
                    if let selectedIndex = selectedSetIndex, let selectedSets = selectedSets, selectedIndex < selectedSets.count {
                        RuleMark(
                            x: .value("Selected", "Set \(selectedIndex + 1)")
                        )
                        .foregroundStyle(Color.red.opacity(0.3))
                        .offset(yStart: -10)
                        .zIndex(1)
                        .annotation(
                            position: .top,
                            alignment: sets.count < 9 ? .trailing : .leading,
                            spacing: 0,
                            overflowResolution: .init(
                                x: .fit(to: .automatic),
                                y: .fit(to: .chart)
                            )
                        ) {
                            valueSelectionPopover(for: selectedSets[selectedIndex])
                        }
                    }
                }
                .chartXSelection(value: $selectedSetIndex)
                .padding(8)
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: 3600 * 24 * 21)
                .chartScrollPosition(initialX: Calendar.current.date(byAdding: .day, value: -19, to: Date()) ?? Date())
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
                .chartYScale(domain: 0...yAxisMax)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                
                Text("Date")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .fixedSize()
                    .frame(width: 15)
                    //.padding(.leading, -15)
            }
        }
    
    }
    
    @ViewBuilder
    func valueSelectionPopover(for set: ExerciseSet) -> some View {
        let padding: CGFloat = -4
            VStack(alignment: .leading) {
                //Text("WEIGHT").foregroundStyle(.gray).padding(.vertical, padding).font(.caption).fontWeight(.semibold)
                
                    HStack {
                        HStack(alignment: .bottom) {
                            Text("\(set.weight)").font(.caption).padding(.vertical, padding).padding(.trailing, padding).fontWeight(.semibold)
                            Text("LBS").foregroundStyle(.gray).padding(.vertical, padding).padding(.bottom, 2).font(.caption).fontWeight(.semibold)
                        }
                        HStack(alignment: .bottom) {
                            Text("\(set.reps)").font(.caption).padding(.vertical, padding).padding(.trailing, padding).fontWeight(.semibold)
                            Text("REPS").foregroundStyle(.gray).padding(.vertical, padding).padding(.bottom, 2).font(.caption).fontWeight(.semibold)
                        }
                        if let duration = set.duration {
                            HStack {
                                Image(systemName: "stopwatch.fill")
                                    .foregroundStyle(.gray)
                                    .font(.caption)
                                DurationView(minutes: Int(duration) / 60, seconds: Int(duration) % 60)
                            }
                        }
                    }
                
            }
            .padding(6)
            .background {
                RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(Color.gray.opacity(0.12))
            }
    }
    
}


