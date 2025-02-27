//
//  CellView.swift
//  MVVMWithCombine
//
//  Created by Felix Hu on 2025/2/27.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
  func loadImageWithCache(from urlString: String) {
    if let cachedImage = imageCache.object(forKey: urlString as NSString) {
      self.image = cachedImage
      return
    }
    
    guard let url = URL(string: urlString) else { return }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
      if let data = data, let image = UIImage(data: data) {
        imageCache.setObject(image, forKey: urlString as NSString)
        DispatchQueue.main.async {
          self.image = image
        }
      }
    }.resume()
  }
}


class CellView: UITableViewCell {
  
  static let staticHeight: CGFloat = 80
  
  @IBOutlet weak var markButton: UIButton!
  @IBOutlet weak var versionLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var iconView: UIImageView!
  
  var onToggleMark: (() -> Void)?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    self.selectionStyle = .none
    self.iconView.layer.cornerRadius = 30
    self.markButton.setImage(UIImage(systemName: "star"), for: .normal)
    self.markButton.setImage(UIImage(systemName: "star.fill"), for: .highlighted)
    self.markButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
    
    self.markButton.addTarget(self, action: #selector(toggleMarkAction), for: .touchUpInside)
  }

  @objc
  private func toggleMarkAction() {
    self.onToggleMark?()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.iconView.image = nil
    self.nameLabel.text = nil
    self.versionLabel.text = nil
    self.markButton.isSelected = false
    self.markButton.tintColor = UIColor.lightGray
  }
  
  func reload(_ item: AppStoreApp, isMarked: Bool) {
    if let url = item.artworkUrl512 {
      self.iconView.loadImageWithCache(from: url)
    } else {
      self.iconView.image = nil
    }
    self.nameLabel.text = item.trackName
    self.versionLabel.text = item.version
    self.markButton.isSelected = isMarked
    self.markButton.tintColor = isMarked ? UIColor.orange : UIColor.lightGray
    
  }
}
