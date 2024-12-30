extension String {
    func withPrefix(_ prefix: String) -> String {
        if self.hasPrefix(prefix) {
            return self
        }

        return prefix + self
    }
}

extension String {
    var isNumeric: Bool {
        Double(self) != nil
    }
}

extension String {
    var lines: [Substring] {
        self.split(separator: .init("\n"))
    }
}

"pet".withPrefix("car")
"14".isNumeric
"this\nis\na\ntest".lines
