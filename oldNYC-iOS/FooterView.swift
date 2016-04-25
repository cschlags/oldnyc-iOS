import UIKit

class FooterView: UIView {
    
    let count: Int
    var yearLabel: UITextView? = UITextView()
    var attributedLabelText: NSMutableAttributedString = NSMutableAttributedString()
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    var year: String{
        didSet {
//            updateYear()
        }
    }
    var summary: String{
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel() {
        yearLabel!.textAlignment = .Left
    }
    
    func updateSummary() {
        var smallSummary = ""
        if self.frame.height != 100.0{
            attributedLabelText = NSMutableAttributedString(string: "\n", attributes: nil)
            attributedLabelText.appendAttributedString(NSAttributedString(string: year, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(20), NSForegroundColorAttributeName: UIColor.whiteColor()]))
            attributedLabelText.appendAttributedString(NSAttributedString(string: "\n", attributes: nil))
            attributedLabelText.appendAttributedString(NSAttributedString(string: summary, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: UIColor.whiteColor()]))
        }else{
            if !summary.isEmpty{
                attributedLabelText = NSMutableAttributedString(string: "\n", attributes: nil)
                attributedLabelText.appendAttributedString(NSAttributedString(string: year, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(20), NSForegroundColorAttributeName: UIColor.whiteColor()]))
                attributedLabelText.appendAttributedString(NSAttributedString(string: "\n", attributes: nil))
                if summary.characters.count > 29{
                    smallSummary = summary.substringToIndex(summary.startIndex.advancedBy(30))
                    if smallSummary.componentsSeparatedByString("\n").count > 1{
                        smallSummary = smallSummary.componentsSeparatedByString("\n")[0] + smallSummary.componentsSeparatedByString("\n")[1]
                    }
                    attributedLabelText.appendAttributedString(NSAttributedString(string: smallSummary, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: UIColor.whiteColor()]))
                    attributedLabelText.appendAttributedString(NSAttributedString(string: "... See More", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: UIColor.grayColor()]))
                        if smallSummary.componentsSeparatedByString("\n").count == 1{
                            attributedLabelText.appendAttributedString(NSAttributedString(string: "\n", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: UIColor.grayColor()]))
                        }else if smallSummary.componentsSeparatedByString("\n").count == 0{
                            attributedLabelText.appendAttributedString(NSAttributedString(string: "\n\n", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: UIColor.grayColor()]))
                        }
                }else{
                    smallSummary = summary
                    attributedLabelText.appendAttributedString(NSAttributedString(string: smallSummary, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: UIColor.whiteColor()]))
                }
            }else{
                attributedLabelText = NSMutableAttributedString(string: "\n\n\n", attributes: nil)
                attributedLabelText.appendAttributedString(NSAttributedString(string: year, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(20), NSForegroundColorAttributeName: UIColor.whiteColor()]))
            }
        }
        updateCredit()
    }
    
    func updateCredit() {
        attributedLabelText.appendAttributedString(NSAttributedString(string: "\n", attributes: nil))
        attributedLabelText.appendAttributedString(NSAttributedString(string: "NYPL Irma and Paul Milstein Collection", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: UIColor.grayColor()]))
        yearLabel?.attributedText = attributedLabelText
    }
    
    func updateGradient(){
        yearLabel?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    }

    func setupTextView() {
        yearLabel = UITextView(frame: CGRectZero, textContainer: nil)
        yearLabel?.translatesAutoresizingMaskIntoConstraints = false
        yearLabel?.editable = false
        yearLabel?.scrollEnabled = true
        yearLabel?.dataDetectorTypes = .None
        yearLabel?.backgroundColor = UIColor.clearColor()
        yearLabel?.textContainerInset = UIEdgeInsetsMake(2.0, 2.0, 0.0, 2.0)
        self.addSubview(yearLabel!)
        let topConstraint: NSLayoutConstraint = NSLayoutConstraint(item: yearLabel!, attribute: .Top, relatedBy: .Equal, toItem: yearLabel!, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint: NSLayoutConstraint = NSLayoutConstraint(item: yearLabel!, attribute: .Bottom, relatedBy: .Equal, toItem: yearLabel!, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let widthConstraint: NSLayoutConstraint = NSLayoutConstraint(item: yearLabel!, attribute: .Width, relatedBy: .Equal, toItem: yearLabel!, attribute: .Width, multiplier: 1.0, constant: 0.0)
        let horizontalPositionConstraint: NSLayoutConstraint = NSLayoutConstraint(item: yearLabel!, attribute: .CenterX, relatedBy: .Equal, toItem: yearLabel!, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        yearLabel!.addConstraints([topConstraint, bottomConstraint, widthConstraint, horizontalPositionConstraint])
        yearLabel?.autocorrectionType = UITextAutocorrectionType.No
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        yearLabel!.frame = self.bounds
        yearLabel!.setContentOffset(CGPointZero, animated: false)
        yearLabel!.contentOffset.x = 0.0
        yearLabel!.contentOffset.y = 0.0
    }
}