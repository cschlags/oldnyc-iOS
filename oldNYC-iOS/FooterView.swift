import UIKit

class FooterView: UIView {
    
    let count: Int
    var yearLabel: UITextView? = UITextView()
    var attributedLabelText: NSMutableAttributedString = NSMutableAttributedString()
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    var year: String {
        didSet {
            updateYear()
        }
    }
    var summary: String {
        didSet {
            updateSummary()
        }
    }
    
    init(frame: CGRect, year: String, summary:String, count: Int) {
        self.year = year
        self.summary = summary
        self.count = count
        
        super.init(frame: frame)
        
        setupTextView()
        updateGradient()
        configureLabel()
        updateYear()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel() {
        yearLabel!.textAlignment = .Left
    }
    
    func updateYear() {
        attributedLabelText = NSMutableAttributedString(string: "", attributes: nil)
        attributedLabelText.appendAttributedString(NSAttributedString(string: year, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(15), NSForegroundColorAttributeName: UIColor.whiteColor()]))
    }
    
    func updateSummary() {
        attributedLabelText.appendAttributedString(NSAttributedString(string: "\n", attributes: nil))
        attributedLabelText.appendAttributedString(NSAttributedString(string: summary, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(15), NSForegroundColorAttributeName: UIColor.whiteColor()]))
        updateCredit()
    }
    
    func updateCredit() {
        attributedLabelText.appendAttributedString(NSAttributedString(string: "\n", attributes: nil))
        attributedLabelText.appendAttributedString(NSAttributedString(string: "NYPL Irma and Paul Milstein Collection", attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(15), NSForegroundColorAttributeName: UIColor.darkGrayColor()]))
        yearLabel?.attributedText = attributedLabelText
    }
    
    func updateGradient(){
        self.gradientLayer = CAGradientLayer()
        self.gradientLayer.frame = (yearLabel?.bounds)!
        self.gradientLayer.colors = [(UIColor.clearColor().CGColor as AnyObject), (UIColor.blackColor().colorWithAlphaComponent(0.85).CGColor as AnyObject)]
        yearLabel?.backgroundColor = UIColor.clearColor()
        yearLabel?.layer.insertSublayer(self.gradientLayer, atIndex: 0)
    }
    
    func setupTextView() {
        
        yearLabel = UITextView(frame: CGRectZero, textContainer: nil)
        yearLabel?.translatesAutoresizingMaskIntoConstraints = false
        yearLabel?.editable = true
        yearLabel?.dataDetectorTypes = .None
        yearLabel?.backgroundColor = UIColor.clearColor()
        yearLabel?.textContainerInset = UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0)
        self.addSubview(yearLabel!)
        let topConstraint: NSLayoutConstraint = NSLayoutConstraint(item: yearLabel!, attribute: .Top, relatedBy: .Equal, toItem: yearLabel!, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint: NSLayoutConstraint = NSLayoutConstraint(item: yearLabel!, attribute: .Bottom, relatedBy: .Equal, toItem: yearLabel!, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let widthConstraint: NSLayoutConstraint = NSLayoutConstraint(item: yearLabel!, attribute: .Width, relatedBy: .Equal, toItem: yearLabel!, attribute: .Width, multiplier: 1.0, constant: 0.0)
        let horizontalPositionConstraint: NSLayoutConstraint = NSLayoutConstraint(item: yearLabel!, attribute: .CenterX, relatedBy: .Equal, toItem: yearLabel!, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        yearLabel!.addConstraints([topConstraint, bottomConstraint, widthConstraint, horizontalPositionConstraint])
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        yearLabel!.frame = self.bounds
    }
}