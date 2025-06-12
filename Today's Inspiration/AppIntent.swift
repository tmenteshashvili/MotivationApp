import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Quote Widget Configuration" }
    static var description: IntentDescription { "Configure your daily motivation quotes." }
}
