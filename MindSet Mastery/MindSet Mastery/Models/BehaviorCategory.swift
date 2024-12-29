import Foundation

struct BehaviorCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let defaultAffirmations: [String]
    
    static let categories: [BehaviorCategory] = [
        BehaviorCategory(
            name: "Anxiety",
            icon: "heart.circle",
            description: "Transform anxiety into calm and confidence",
            defaultAffirmations: [
                "I am safe and in control of my thoughts",
                "With each breath, I release anxiety and welcome peace",
                "I choose to respond to life with calmness and clarity"
            ]
        ),
        BehaviorCategory(
            name: "Self-Doubt",
            icon: "person.fill.checkmark",
            description: "Build unwavering self-confidence",
            defaultAffirmations: [
                "I trust in my abilities and inner wisdom",
                "I am worthy of success and happiness",
                "My potential is limitless"
            ]
        ),
        BehaviorCategory(
            name: "Procrastination",
            icon: "clock.fill",
            description: "Overcome delay and take action",
            defaultAffirmations: [
                "I take immediate action towards my goals",
                "I choose productivity over procrastination",
                "I am focused and efficient in all I do"
            ]
        ),
        BehaviorCategory(
            name: "Anger",
            icon: "flame.fill",
            description: "Transform anger into inner peace",
            defaultAffirmations: [
                "I choose peace over anger",
                "I respond to challenges with calmness",
                "I am in control of my emotions"
            ]
        ),
        BehaviorCategory(
            name: "Fear",
            icon: "shield.fill",
            description: "Face fears with courage",
            defaultAffirmations: [
                "I am stronger than my fears",
                "I face challenges with courage",
                "Every obstacle is an opportunity for growth"
            ]
        ),
        BehaviorCategory(
            name: "Stress",
            icon: "leaf.fill",
            description: "Find calm in chaos",
            defaultAffirmations: [
                "I choose to remain calm under pressure",
                "Stress flows through me and dissolves",
                "I am centered and peaceful"
            ]
        ),
        BehaviorCategory(
            name: "Depression",
            icon: "sun.max.fill",
            description: "Cultivate inner light and joy",
            defaultAffirmations: [
                "I deserve happiness and joy",
                "Each day brings new hope and possibilities",
                "I am worthy of love and happiness"
            ]
        ),
        BehaviorCategory(
            name: "Addiction",
            icon: "arrow.up.forward.circle.fill",
            description: "Break free and reclaim control",
            defaultAffirmations: [
                "I am stronger than my impulses",
                "I choose healthy alternatives",
                "Each day I grow stronger in my recovery"
            ]
        ),
        BehaviorCategory(
            name: "Relationships",
            icon: "heart.fill",
            description: "Nurture meaningful connections",
            defaultAffirmations: [
                "I attract healthy and positive relationships",
                "I am worthy of love and respect",
                "I communicate with openness and honesty"
            ]
        ),
        BehaviorCategory(
            name: "Confidence",
            icon: "star.fill",
            description: "Embrace your inner strength",
            defaultAffirmations: [
                "I am confident in my abilities",
                "I radiate confidence and self-assurance",
                "I trust my inner wisdom"
            ]
        ),
        BehaviorCategory(
            name: "Motivation",
            icon: "bolt.fill",
            description: "Ignite your inner drive",
            defaultAffirmations: [
                "I am driven and motivated to achieve my goals",
                "My potential is limitless",
                "I take consistent action towards my dreams"
            ]
        ),
        BehaviorCategory(
            name: "Focus",
            icon: "target",
            description: "Sharpen your concentration",
            defaultAffirmations: [
                "I maintain laser-like focus on my goals",
                "I am present and focused in all I do",
                "My mind is clear and concentrated"
            ]
        ),
        BehaviorCategory(
            name: "Sleep",
            icon: "moon.fill",
            description: "Achieve restful sleep",
            defaultAffirmations: [
                "I easily fall into deep, restful sleep",
                "My mind and body are ready for peaceful rest",
                "I wake up refreshed and energized"
            ]
        ),
        BehaviorCategory(
            name: "Forgiveness",
            icon: "hand.raised.fill",
            description: "Release and heal",
            defaultAffirmations: [
                "I choose to forgive and release the past",
                "Forgiveness sets me free",
                "I embrace peace and let go of resentment"
            ]
        ),
        BehaviorCategory(
            name: "Gratitude",
            icon: "gift.fill",
            description: "Cultivate appreciation",
            defaultAffirmations: [
                "I am grateful for all that I have",
                "Each day brings new blessings",
                "My life is filled with abundance"
            ]
        )
    ]
} 