import Foundation

class Analytics {
    static let shared = Analytics()
    
    private var orgId: String? = nil
    private var options: CommandBarInternalOptions? = nil
    private var userId: String? = nil
    private var session: String? = nil
    private var serverQueue: [EventPayload] = []
    
    func setup(orgId: String, with options: CommandBarInternalOptions? = nil) {
        self.orgId = orgId
        self.options = options
        self.session = genSession()
        
        Analytics.shared.identify()
    }
    
    func identify() {
        guard let organization = Analytics.shared.orgId else { return }
        
        let properties = UserProperties(id: self.options?.user_id)
        let body = AnalyticsIdentifyBody(organization_id: organization, distinct_id: self.options?.user_id, properties: properties)
        guard let bodyData = try? JSONEncoder().encode(body) else {
            print("CommandBar Analytics: Error building identity request")
            return
        }
        
        
        guard let url = self.options?.getAPIUrl(for: .analytics, with: "/t/identify/") else {
            print("CommandBar Analytics: Error building identity request")
            return
        }
    
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("CommandBar Analytics: Error identifying user")
                print(error)
            }
        }

        task.resume()
    }
    
    func log(eventName: EventName, data: EventAttributes) {
        switch(eventName) {
        case .surveyResponse:
            self.addEventToServerQueue(type: .log, name: eventName, attrs: data)
            // Always flush until full analytics is built out
            self.flushServerQueue()
        }
    }
    
    // Generated in the same way we do on the web
    private func genSession() -> String {
        let len = 12
        let factor = pow(10.0, Double(len))
        let randomValue = Double.random(in: 1...9)
        let result = floor(factor + randomValue * factor)
        return String(Int(result))
    }
    
    
    // Just handles one event in the queue but it will support multiple as soon as that is setup (if we want it to be)
    private func flushServerQueue() {
        guard let organization = Analytics.shared.orgId else { return }
        

        let events = self.serverQueue
        
        let body = AnalyticsTrackBody(events: events, organization: organization, id: Analytics.shared.userId)
        
        guard let bodyData = try? JSONEncoder().encode(body) else {
            print("Error decoding body")
            return
        }
        
        guard let url = self.options?.getAPIUrl(for: .analytics, with: "/t/") else {
            print("Error forming URL")
            return
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            }
        }

        task.resume()
    }
    
    
    private func enrichEvent(type: AnalyticsType, name: EventName, attrs: EventAttributes) -> EventPayload {
        let context = EventPayload.Context(page: nil, userAgent: nil, groupId: nil, cbSource: nil)
        let payload = EventPayload(
            context: context,
            userType: .endUser,
            type: type,
            attrs: attrs,
            name: name,
            id: Analytics.shared.userId,
            session: session,
            search: nil,
            reportToSegment: false,
            fingerprint: nil,
            clientEventTimestamp: Date().getCurrentTimeStamp(),
            clientFlushedTimestamp: Date().getCurrentTimeStamp()
        )
        
        return payload
    }
    
    private func addEventToServerQueue(type: AnalyticsType, name: EventName, attrs: EventAttributes) {
        let enrichedEvent = self.enrichEvent(type: type, name: name, attrs: attrs);
        self.serverQueue.append(enrichedEvent);
    }

}

extension Date {
    func getCurrentTimeStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: self)
    }
}
