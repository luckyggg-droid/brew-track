import CoreText
import Foundation

enum FontRegistration {
    static func registerFonts() {
        registerFont(named: "PatrickHand-Regular", extension: "ttf")
    }

    private static func registerFont(named name: String, extension fileExtension: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
            return
        }

        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
}
