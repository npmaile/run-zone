import Foundation
import Combine

class IntervalTimer: ObservableObject {
    @Published var isRunning = false
    @Published var currentPhase: IntervalPhase = .warmup
    @Published var timeRemaining: TimeInterval = 0
    @Published var totalIntervals: Int = 0
    @Published var currentInterval: Int = 0
    @Published var totalTime: TimeInterval = 0
    
    private var timer: Timer?
    private var intervals: [IntervalPhase] = []
    private var currentPhaseIndex = 0
    private var phaseStartTime: Date?
    
    // MARK: - Preset Workouts
    
    static func createCouchTo5K_Week1() -> [IntervalPhase] {
        var phases: [IntervalPhase] = []
        phases.append(.warmup(duration: 300)) // 5 min warmup
        
        // 8 intervals of: 60s run, 90s walk
        for _ in 0..<8 {
            phases.append(.work(duration: 60))
            phases.append(.rest(duration: 90))
        }
        
        phases.append(.cooldown(duration: 300)) // 5 min cooldown
        return phases
    }
    
    static func create5x5Intervals() -> [IntervalPhase] {
        var phases: [IntervalPhase] = []
        phases.append(.warmup(duration: 600)) // 10 min warmup
        
        // 5 intervals of: 5 min fast, 2 min recovery
        for _ in 0..<5 {
            phases.append(.work(duration: 300))
            phases.append(.rest(duration: 120))
        }
        
        phases.append(.cooldown(duration: 600)) // 10 min cooldown
        return phases
    }
    
    static func createTempoRun(minutes: Int) -> [IntervalPhase] {
        var phases: [IntervalPhase] = []
        phases.append(.warmup(duration: 600)) // 10 min warmup
        phases.append(.work(duration: TimeInterval(minutes * 60))) // Tempo portion
        phases.append(.cooldown(duration: 600)) // 10 min cooldown
        return phases
    }
    
    static func createCustom(warmup: Int, work: Int, rest: Int, intervals: Int, cooldown: Int) -> [IntervalPhase] {
        var phases: [IntervalPhase] = []
        
        if warmup > 0 {
            phases.append(.warmup(duration: TimeInterval(warmup)))
        }
        
        for _ in 0..<intervals {
            phases.append(.work(duration: TimeInterval(work)))
            if rest > 0 {
                phases.append(.rest(duration: TimeInterval(rest)))
            }
        }
        
        if cooldown > 0 {
            phases.append(.cooldown(duration: TimeInterval(cooldown)))
        }
        
        return phases
    }
    
    // MARK: - Control
    
    func start(intervals: [IntervalPhase]) {
        self.intervals = intervals
        self.currentPhaseIndex = 0
        self.currentInterval = 0
        self.totalIntervals = intervals.filter { $0.isWorkPhase }.count
        self.totalTime = intervals.reduce(0) { $0 + $1.duration }
        
        startNextPhase()
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resume() {
        if !intervals.isEmpty && currentPhaseIndex < intervals.count {
            isRunning = true
            startTimer()
        }
    }
    
    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        currentPhaseIndex = 0
        currentInterval = 0
        timeRemaining = 0
    }
    
    func skip() {
        timer?.invalidate()
        currentPhaseIndex += 1
        
        if currentPhaseIndex < intervals.count {
            startNextPhase()
        } else {
            workoutComplete()
        }
    }
    
    // MARK: - Private Methods
    
    private func startNextPhase() {
        guard currentPhaseIndex < intervals.count else {
            workoutComplete()
            return
        }
        
        currentPhase = intervals[currentPhaseIndex]
        timeRemaining = currentPhase.duration
        phaseStartTime = Date()
        isRunning = true
        
        if currentPhase.isWorkPhase {
            currentInterval += 1
        }
        
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeRemaining -= 1
            
            if self.timeRemaining <= 0 {
                self.timer?.invalidate()
                self.currentPhaseIndex += 1
                self.startNextPhase()
            }
        }
    }
    
    private func workoutComplete() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Interval Phase

enum IntervalPhase {
    case warmup(duration: TimeInterval)
    case work(duration: TimeInterval)
    case rest(duration: TimeInterval)
    case cooldown(duration: TimeInterval)
    
    var duration: TimeInterval {
        switch self {
        case .warmup(let duration),
             .work(let duration),
             .rest(let duration),
             .cooldown(let duration):
            return duration
        }
    }
    
    var name: String {
        switch self {
        case .warmup: return "Warm Up"
        case .work: return "Work"
        case .rest: return "Rest"
        case .cooldown: return "Cool Down"
        }
    }
    
    var icon: String {
        switch self {
        case .warmup: return "figure.walk"
        case .work: return "bolt.fill"
        case .rest: return "pause.circle"
        case .cooldown: return "figure.walk"
        }
    }
    
    var color: String {
        switch self {
        case .warmup: return "blue"
        case .work: return "red"
        case .rest: return "green"
        case .cooldown: return "blue"
        }
    }
    
    var isWorkPhase: Bool {
        if case .work = self {
            return true
        }
        return false
    }
}
