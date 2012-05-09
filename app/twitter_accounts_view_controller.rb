class TwitterAccountsViewController < UITableViewController
  CellIdentifier = 'AccountCell'
  
  def viewDidLoad
    @accounts = []

    setTitle("Accounts")
    loadTwitterAccounts
  end

  def tableView(tv, numberOfRowsInSection: section)
    @accounts.size
  end

  def tableView(tv, cellForRowAtIndexPath: indexPath)
    cell = tv.dequeueReusableCellWithIdentifier(CellIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: CellIdentifier)
    end

    cell.textLabel.text = @accounts[indexPath.row].username
    cell
  end

  def tableView(tv, didSelectRowAtIndexPath: indexPath)
    timelineController = TwitterHomeTimelineViewController.alloc.init
    timelineController.twitterAccount = @accounts[indexPath.row]

    navigationController.pushViewController(timelineController, animated: true)
  end
  
  def loadTwitterAccounts
    @accountStore = ACAccountStore.alloc.init
    @twitterAccountType = @accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)

    @accountStore.requestAccessToAccountsWithType @twitterAccountType, withCompletionHandler: -> granted, error {
      unless granted
        UIApplication.sharedApplication.terminateWithSuccess
      end

      twitterAccounts = @accountStore.accountsWithAccountType(@twitterAccountType) || []
      @accounts = twitterAccounts
      view.performSelectorOnMainThread('reloadData', withObject: nil, waitUntilDone: false)
    }
  end
end
