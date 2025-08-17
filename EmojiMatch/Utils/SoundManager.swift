import AudioToolbox

class SoundManager {
    static func playCardFlip() {
        AudioServicesPlaySystemSound(1104)
    }
    
    static func playMatch() {
        AudioServicesPlaySystemSound(1103)
    }
    
    static func playNoMatch() {
        AudioServicesPlaySystemSound(1105)
    }
    
    static func playWin() {
        AudioServicesPlaySystemSound(1000)
    }
    
    static func playLose() {
        AudioServicesPlaySystemSound(1006)
    }
    
    // NEW: Countdown sounds
    static func playCountdownTick() {
        // Uses a lighter sound for countdown numbers
        AudioServicesPlaySystemSound(1057) // SMS tone 1
    }
    
    static func playCountdownStart() {
        // Uses a more triumphant sound for "GO!"
        AudioServicesPlaySystemSound(1016) // SMS tone 2
    }
}
