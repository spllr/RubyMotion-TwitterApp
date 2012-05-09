class TwitterHomeTimelineViewController < UITableViewController

  attr_accessor :twitterAccount
  attr_accessor :statuses
  attr_accessor :fetching

  StatusCellIdentifier = 'StatusCell'

  def viewDidLoad
    fetching = false
    setTitle(twitterAccount.username)
    @statuses = []
    
    navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCompose,
                                                                                         target: self,
                                                                                         action: 'composeTweet')


    @reloadButton = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemRefresh,
                                                                     target: self,
                                                                     action: 'loadTimeline')

    flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace,
                                                                      target: nil,
                                                                      action: nil)
    setToolbarItems([flexibleSpace, @reloadButton])
  end

  def viewWillAppear(animated)
    navigationController.setToolbarHidden(false, animated: animated)
    @timer = NSTimer.scheduledTimerWithTimeInterval(40, target: self, selector: 'loadTimeline', userInfo: nil, repeats: true)
    loadTimeline
  end

  def viewWillDisappear(animated)
    @timer.invalidate
    @times = nil
    navigationController.setToolbarHidden(true, animated: animated)
  end

  def tableView(tv, numberOfRowsInSection: section)
    statuses.size
  end

  def tableView(tv, cellForRowAtIndexPath: indexPath)
    cell = tv.dequeueReusableCellWithIdentifier(StatusCellIdentifier) ||
      StatusCell.alloc.initWithReuseIdentifier(StatusCellIdentifier)

    cell.tweet = statuses[indexPath.row]
    cell
  end

  def tableView(tv, heightForRowAtIndexPath: indexPath)
    StatusCell.heightForCellWithTweet(statuses[indexPath.row])
  end
 
  def fetching=(state)
    @reloadButton.enabled = !state
    @fetching = state
  end

  def loadTimeline
    return if fetching
    
    puts "fetching timeline"
    fetching = true

    params = {
      "count" => "200"
    }
    params["since_id"] = @since_id if @since_id

    url = NSURL.URLWithString("https://api.twitter.com/1/statuses/home_timeline.json")
    timelineRequest = TWRequest.alloc.initWithURL(url, parameters: params, requestMethod: TWRequestMethodGET)
    timelineRequest.account = twitterAccount

    timelineRequest.performRequestWithHandler -> responseData, urlResponse, error {
      if responseData
        error = Pointer.new(:id)
        timelineData = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingMutableLeaves, error: error)
        
        unless timelineData.empty?
          @since_id = timelineData[0]["id_str"]
          @statuses = timelineData.map { |data| Tweet.new(data) } + @statuses
        end
        
        view.performSelectorOnMainThread('reloadData', withObject: nil, waitUntilDone: false)
        performSelectorOnMainThread('fetching=:', withObject: false, waitUntilDone: false)
      else
        # TODO Implement error handling
      end
    }
  end

  def composeTweet
    tweetController = TWTweetComposeViewController.alloc.init

    tweetController.initialText = "Tweeting from RubyMotion!"
    tweetController.setCompletionHandler -> result {
      case result
      when TWTweetComposeViewControllerResultCancelled
        puts "The tweet was cancelled"
      when TWTweetComposeViewControllerResultDone
        puts "The tweet was send!"
      end
      dismissModalViewControllerAnimated(true)
    }

    presentModalViewController(tweetController, animated: true)
  end
end
