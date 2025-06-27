//
//  SchoolWidgetLiveActivity.swift
//  SchoolWidget
//
//  Created by Carl on 26.06.25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SchoolWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SchoolWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SchoolWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SchoolWidgetAttributes {
    fileprivate static var preview: SchoolWidgetAttributes {
        SchoolWidgetAttributes(name: "World")
    }
}

extension SchoolWidgetAttributes.ContentState {
    fileprivate static var smiley: SchoolWidgetAttributes.ContentState {
        SchoolWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SchoolWidgetAttributes.ContentState {
         SchoolWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SchoolWidgetAttributes.preview) {
   SchoolWidgetLiveActivity()
} contentStates: {
    SchoolWidgetAttributes.ContentState.smiley
    SchoolWidgetAttributes.ContentState.starEyes
}
