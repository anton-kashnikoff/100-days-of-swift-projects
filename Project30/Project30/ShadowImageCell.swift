import UIKit

final class ShadowImageCell: UITableViewCell {
    private let shadowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 1
        imageView.layer.shadowRadius = 10
        imageView.layer.shadowOffset = .zero
        imageView.layer.cornerRadius = 45
        imageView.layer.shadowPath = UIBezierPath(
            ovalIn: CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
        ).cgPath
        
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 1
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(shadowImageView)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            shadowImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            shadowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            shadowImageView.widthAnchor.constraint(equalToConstant: 90),
            shadowImageView.heightAnchor.constraint(equalToConstant: 90),
            titleLabel.leadingAnchor.constraint(equalTo: shadowImageView.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with image: UIImage?, text: String) {
        shadowImageView.image = image
        titleLabel.text = text
    }
}
