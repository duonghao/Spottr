//
//  SetList.swift
//  Spottr
//
//  Created by Hao Duong on 14/8/2023.
//

import SwiftUI

struct EqualWidthHStack: Layout {
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let maxSize: CGSize = maxSize(subviews: subviews)
        let spacing: [CGFloat] = spacing(subviews: subviews)
        let totalSpacing = spacing.reduce(0) { $0 + $1 }

        return CGSize(
            width: maxSize.width * CGFloat(subviews.count) + totalSpacing,
            height: maxSize.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }

        let maxSize = maxSize(subviews: subviews)
        let spacing = spacing(subviews: subviews)

        let placementProposal = ProposedViewSize(width: maxSize.width, height: maxSize.height)
        var nextX = bounds.minX + maxSize.width / 2

        for index in subviews.indices {
            subviews[index].place(
                at: CGPoint(x: nextX, y: bounds.midY),
                anchor: .center,
                proposal: placementProposal)
            nextX += maxSize.width + spacing[index]
        }
    }
    
    private func maxSize(subviews: Subviews) -> CGSize {
        let subViewSizes = subviews.map({$0.sizeThatFits(.unspecified)})
        let maxSize: CGSize = subViewSizes.reduce(.zero) { maxSize, currentSize in
            return CGSize(
                width: max(maxSize.width, currentSize.width),
                height: max(maxSize.height, currentSize.height)
            )
        }
        
        return maxSize
    }
    
    private func spacing(subviews: Subviews) -> [CGFloat] {
        subviews.indices.map { index in
            guard index < subviews.count - 1 else { return 0 }
            return subviews[index].spacing.distance(
                to: subviews[index + 1].spacing,
                along: .horizontal)
        }
    }
    
}

struct SetList: View {
    
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var exercise: Exercise
    private let headers: [HeaderItem] = [
        .init(title: "set"),
        .init(title: "last"),
        .init(title: "weight"),
        .init(title: "reps"),
        .init(title: "done")
    ]

    var body: some View {
        LazyVStack(spacing: 0) {
            HStack {
                ForEach(headers) { header in
                    GeometryReaderView {
                        Text(header.title.capitalized)
                            .font(.headline)
                    }
                }
            }
            .padding(.vertical)
            
            Divider()
            
            ForEach(Array(exercise.setsArray.enumerated()), id: \.offset) { index, exerciseSet in
                SetRow(exercise: exercise, set: exerciseSet, order: index + 1, lastSet: priorSet(from: index))
            }

            HStack {
                Button {
                    withAnimation {
                        addSet()
                    }
                } label: {
                    Label("New set", systemImage: "plus")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.top)
    }
    
    func addSet() {
        let newSet = ExerciseSet(context: moc)
        newSet.id = UUID()
        
        exercise.addToSets(newSet)
        
        save()
    }
    
    func priorSet(from index: Int) -> ExerciseSet? {
        index == 0 ? priorExercise?.setsArray.last : exercise.setsArray[index - 1]
    }
    
    var priorExercise: Exercise? {
        Exercise.getPriorExercise(exercise: exercise)
    }

    func deleteSet(at offsets: IndexSet) {
        for index in offsets {
            let set = exercise.setsArray[index]
            exercise.removeFromSets(set)
            moc.delete(set)
        }
        save()
    }
    
    func save() {
        PersistenceController.shared.save()
    }
}

struct SetList_Previews: PreviewProvider {
    static var previews: some View {
        SetList(exercise: Exercise.example)
    }
}
