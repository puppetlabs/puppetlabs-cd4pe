class CD4PETaskLogger < Object
  # Class to track logs + timestamps. To be returned as part of the Bolt log output
  def initialize
    @logs = []
  end

  def log(log)
    @logs.push(timestamp: Time.now.getutc, message: log)
  end

  def get_logs
    @logs
  end
end
