include Sidekiq::Worker

class PendingFaxJob
  sidekiq_options queue: 'pending_fax'

  def perform(*args)
    # Do something
  end

end
