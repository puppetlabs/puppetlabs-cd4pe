# Class to track logs + timestamps. To be returned as part of the Bolt log output
class CD4PETaskLogger < Object
  attr_reader :logs
  def initialize
    @logs = []
  end

  def log(log)
    @logs.push(timestamp: Time.now.getutc, message: log)
  end
end
