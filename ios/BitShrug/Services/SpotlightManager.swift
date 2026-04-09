import CoreSpotlight
import MobileCoreServices

class SpotlightManager {
    static let shared = SpotlightManager()

    private init() {}

    func indexContent(score: Int, label: String, price: String) {
        var items: [CSSearchableItem] = []

        let envAttributes = CSSearchableItemAttributeSet(contentType: .text)
        envAttributes.title = "Bitcoin Environment Score: \(score)"
        envAttributes.contentDescription = "Current environment is \(label). Bitcoin price: \(price)"
        envAttributes.keywords = ["bitcoin", "environment", "score", "crypto", "btc"]

        let envItem = CSSearchableItem(
            uniqueIdentifier: "bitshrug.environment",
            domainIdentifier: "com.bitshrug",
            attributeSet: envAttributes
        )
        items.append(envItem)

        let priceAttributes = CSSearchableItemAttributeSet(contentType: .text)
        priceAttributes.title = "Bitcoin Price: \(price)"
        priceAttributes.contentDescription = "Current Bitcoin price with Environment Score of \(score) (\(label))"
        priceAttributes.keywords = ["bitcoin", "price", "btc", "crypto"]

        let priceItem = CSSearchableItem(
            uniqueIdentifier: "bitshrug.price",
            domainIdentifier: "com.bitshrug",
            attributeSet: priceAttributes
        )
        items.append(priceItem)

        CSSearchableIndex.default().indexSearchableItems(items)
    }
}
