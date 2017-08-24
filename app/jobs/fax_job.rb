include Sidekiq::Worker

class FaxJob
  sidekiq_options queue: 'send_fax'

  def perform(*args)
    # Do something
  end
  
end
