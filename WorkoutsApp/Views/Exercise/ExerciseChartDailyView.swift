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
    
    var displayedDateStart: Date
    var displayedDateSets: [ExerciseSet]
    var sortByWeight: Bool
    var sortByReps: Bool
    var sortByTime: Bool
    
    @Binding var selectedSetIndex: Int?
    
    var body: some View {
            let maxWeight = displayedDateSets.max(by: { $0.weight < $1.weight })?.weight ?? 0
            let maxReps = displayedDateSets.max(by: { $0.reps < $1.reps })?.reps ?? 0
            let maxDuration = displayedDateSets.compactMap { $0.duration }.max() ?? 0
            
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
                    
                    Text("Sets for \(displayedDateStart, format: .dateTime.month().day().year())")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.gray)
                        .fixedSize()
                        .frame(width: 15)
                        .padding(.vertical, -10)
                    
                    Chart {
                        ForEach(Array(displayedDateSets.enumerated()), id: \.element.id) { index, set in
                            if sortByWeight && !sortByReps && !sortByTime {
                                BarMark(
                                    x: .value("Set", index + 1),
                                    y: .value("Weight", set.weight)
                                )
                            }
                            else if !sortByWeight && sortByReps && !sortByTime {
                                BarMark(
                                    x: .value("Set", index + 1),
                                    y: .value("Reps", set.reps)
                                )
                            } else if !sortByWeight && !sortByReps && sortByTime {
                                BarMark(
                                    x: .value("Set", index + 1),
                                    y: .value("Duration", set.duration ?? 0)
                                )
                            }
                        }
                        .foregroundStyle(.blue)
                        
                        
                        if let selectedSetIndex, selectedSetIndex >= 0, selectedSetIndex < displayedDateSets.count {
                            RuleMark(
                                x: .value("Selected", selectedSetIndex + 1)
                            )
                            .foregroundStyle(Color.red.opacity(0.3))
                            .offset(yStart: 50)
                            .zIndex(1)
                            .annotation(
                                position: .top,
                                alignment: .center,
                                spacing: 0,
                                overflowResolution: .init(
                                    x: .fit(to: .automatic),
                                    y: .fit(to: .automatic)
                                )
                            ) {
                                if selectedSetIndex < displayedDateSets.count {
                                    valueSelectionPopover(for: displayedDateSets[selectedSetIndex])
                                }
                            }
                        }
                        
                    }/*
                    .chartXSelection(value: Binding(
                        get: { selectedSetIndex.map { $0 + 1 } },
                        set: { newValue in
                            if let newValue {
                                selectedSetIndex = newValue - 1
                            } else {
                                selectedSetIndex = nil
                            }
                        }
                    )) */
                    .chartXSelection(value: Binding(
                        get: { selectedSetIndex.map { $0 + 1 } },
                        set: { newValue in
                            selectedSetIndex = newValue.map { $0 - 1 }
                        }
                    ))
                    .padding(8)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: 1)) { value in
                            if let intValue = value.as(Int.self), intValue > 0 && intValue <= displayedDateSets.count {
                                AxisValueLabel {
                                    Text("\(intValue)")
                                }
                                AxisTick()
                                AxisGridLine()
                            }
                        }
                    }
                    .chartXScale(domain: 1...Double(displayedDateSets.count))
                    .chartYScale(domain: 0...yAxisMax)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    
                    Text("Set")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .fixedSize()
                        .frame(width: 15)
                    
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


