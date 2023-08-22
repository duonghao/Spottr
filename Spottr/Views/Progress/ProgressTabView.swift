//
//  ProgressTabView.swift
//  Spottr
//
//  Created by Hao Duong on 10/8/2023.
//

import OrderedCollections
import SwiftUI
import Charts

struct ProgressTabView: View {
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "endDate != nil")) var workouts: FetchedResults<Workout>
    @State private var filters: [ChartFilter] = []
    @State private var metric: Metric = .weight
    @State private var selectedExercises: [ExerciseType] = []
    @State private var showingSelection: Bool = false
    
    var body: some View {
        VStack {
            NavigationStack {
                Chart {
                    ForEach(filteredData.elements, id: \.key) { filter, workouts in
                        ForEach(workouts) { workout in
                            if filter.isOn, let selectedMetric = Metric.calculateMetric(workout: workout, exerciseType: filter.exerciseType, metric: metric) {
                                LineMark(
                                    x: .value("Date", workout.uEndDate),
                                    y: .value(metric.rawValue.capitalized, selectedMetric)
                                )
                                .foregroundStyle(by: .value("Exercise", filter.exerciseType.name.capitalized))
                            }
                        }
                    }
                    RuleMark(
                        y: .value("Threshold", 100)
                    )
                    .foregroundStyle(.red)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 1)) { value in
                        AxisValueLabel(format: Date.FormatStyle(date: .abbreviated, time: .omitted))
                        AxisGridLine()
                        AxisTick()
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: .defaultCornerRadius).fill(.thinMaterial).shadow(radius: .defaultShadowRadius))
                .padding(.horizontal)
                
                Picker("Metric", selection: $metric) {
                    ForEach(Metric.allCases) { metric in
                        Text(metric.rawValue.capitalized).tag(metric)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                List {
                    ForEach(Array(filters.enumerated()), id: \.offset) { index, filter in
                        Toggle(filter.exerciseType.name.capitalized, isOn: $filters[index].isOn)
                    }
                    .onDelete(perform: removeSelectedExercise)
                }
                .listStyle(.grouped)
            }
        }
        .sheet(isPresented: $showingSelection) {
            SelectExerciseView(selectedExercises: $selectedExercises)
        }
        .onChange(of: selectedExercises) { newValue in
            updateFilters(selectedExercises: newValue)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add Exercise") { showingSelection = true }
            }
        }
    }
    
    func removeSelectedExercise(at offsets: IndexSet) {
        selectedExercises.remove(atOffsets: offsets)
    }
    
    func updateFilters(selectedExercises: [ExerciseType]) {
        filters = selectedExercises.map { exerciseType in
            filters.first(where: { $0.exerciseType == exerciseType }) ?? .init(exerciseType: exerciseType, isOn: true)
        }
    }
    
    var filteredData: OrderedDictionary<ChartFilter, [Workout]> {
        var res: OrderedDictionary<ChartFilter, [Workout]> = [:]
        for filter in filters {
            let filtered: [Workout] = workouts.sorted(by: {$0.uEndDate < $1.uEndDate}).filter( { $0.exercisesArray.contains { $0.exerciseType == filter.exerciseType }} )
            res.updateValue(filtered, forKey: filter)
        }
        return res
    }
}

struct ProgressTabView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressTabView()
    }
}
