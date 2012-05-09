class StatusCell < UITableViewCell
  TextFontSize = 12
  DetailLabelFontSize = 14
  Margin = 14

  def initWithReuseIdentifier(identifier)
    if initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier: identifier)
      textLabel.font = UIFont.boldSystemFontOfSize(TextFontSize)
      textLabel.textColor = UIColor.darkGrayColor

      detailTextLabel.numberOfLines = 0
      detailTextLabel.lineBreakMode = UILineBreakModeWordWrap
      detailTextLabel.frame.origin.y = TextFontSize + 2 * Margin
      detailTextLabel.textColor = UIColor.blackColor

      imageView.image = UIImage.imageNamed('avatarPlaceHolder.png')
    end
    self
  end

  def tweet=(tweet)
    textLabel.text = tweet.user["name"]
    detailTextLabel.text = tweet.text
    
    if tweet.avatar
      imageView.image = tweet.avatar
      return
    end

    imageView.image = UIImage.imageNamed('avatarPlaceHolder.png')
    Dispatch::Queue.concurrent.async do
      profile_image_data = NSData.alloc.initWithContentsOfURL(NSURL.URLWithString(tweet.avatar_url))
      if profile_image_data
        tweet.avatar = UIImage.alloc.initWithData(profile_image_data)
        Dispatch::Queue.main.sync do
          imageView.image = tweet.avatar
        end
      end
    end
  end

  def layoutSubviews
    super
    imageView.frame = [[10, Margin], [48, 48]]
  end

  class << self
    def heightForCellWithTweet(tweet)
      @calculationCell ||= StatusCell.alloc.initWithReuseIdentifier('StatusCellCalculationCell')
      @detailLabelOffsetY ||= TextFontSize + 2 * Margin

      appWidth = UIScreen.mainScreen.applicationFrame.size.width
      labelWidth = (appWidth - @calculationCell.imageView.frame.size.width) - 4 * Margin
      constraint = CGSizeMake(labelWidth, 20000)
      
      detailLabelHeight = tweet.text.sizeWithFont(UIFont.systemFontOfSize(DetailLabelFontSize),
                                                constrainedToSize: constraint,
                                                lineBreakMode: UILineBreakModeWordWrap).height

      
      [44 + 2 * Margin, detailLabelHeight + @detailLabelOffsetY].max
    end
  end
end
