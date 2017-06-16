class NormalWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"

  def perform( recipient_name, recipient_number, attachment_from_params, fax_record_id )
    original_file_name, attachments_array = get_attachments(attachment_from_params)
    FaxServices::Fax.actual_sending( recipient_name, recipient_number, attachments_array, fax_record_id )
  end

private
  def get_attachments(array)
    original_file_name = ''
    attachments = []
    array.each_with_index do |file_info|
      file_info = WebServices::Web.file_path(file_info[0], file_info[1])
      attachments << file_info[0]
      original_file_name += file_info[1]
    end
    return original_file_name, attachments
  end

end



#
#
#
#
# def perform( recipient_name, recipient_number, attachments, fax_record_id )
#
#
#   if server Running
#
#     FaxServices::Fax.actual_sending( recipient_name, recipient_number, attachments, fax_record_id )
#
#   else # server id Down ?
#
#     put the fax to the queue and perform later
#
#   end
#
#   FaxServices::Fax.actual_sending( recipient_name, recipient_number, attachments, fax_record_id )
# end
#
#
#




#
# sidekiq_options :retry => 5   # here will retry 5 time and then declear dead to the jobs queue
# sidekiq_options :retry => false # job will be discarded immediately if failed
# sidekiq_options :retry => 5, :dead => false #disable a job going to the Dead job queue


=begin
  The retry delay can be customized using sidekiq_retry_in, if needed.
  The current retry count is yielded. The return value of the block must be an integer. It is used as the delay, in seconds
=end
#
# sidekiq_retry_in do |count
#   10 * (count + 1) # (i.e. 10, 20, 30, 40, 50
# end




=begin
  After retrying so many times, Sidekiq will call the sidekiq_retries_exhausted hook on your Worker if you've defined it.
  The hook receives the queued message as an argument.
  This hook is called right before Sidekiq moves the job to the DJQ.
=end

# sidekiq_retries_exhausted do |msg, e|
#   Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
# end

=begin
  Sidekiq allows you to schedule the time when a job will be executed. You use
  # MyWorker.perform_in(3.hours, 'mike', 1)
  # MyWorker.perform_at(3.hours.from_now, 'mike', 1)
=end

=begin
  Sidekiq's scheduler is not meant to be second-precise.
  It checks for scheduled jobs approximately every 15 seconds by default. You can adjust this interval:
  # Sidekiq.configure_server do |config|
  #   config.average_scheduled_poll_interval = 15
  # end
=end

=begin
  Delayed extensions provide a very easy and simple way to make method calls asynchronous.
  By default, all class methods and ActionMailer deliveries can be performed asynchronously.
ActionMailer
  Use delay to deliver your emails asynchronously. Use delay_for(interval) or delay_until(time) to deliver the email at some point in the future.
  # UserMailer.delay.welcome_email(@user.id)
  # UserMailer.delay_for(5.days).find_more_friends_email(@user.id)
  # UserMailer.delay_until(5.days.from_now).find_more_friends_email(@user.id)
  It is recommended to avoid passing an object instance to mailer methods. Instead, pass an object id and then re-instantiate the object in the mailer method, per Best Practices.
  You can also easily extend the devise gem to send emails using sidekiq.

ActiveRecord
  Use delay, delay_for(interval), or delay_until(time) to asynchronously execute arbitrary methods on your ActiveRecord classes.
  # User.delay.delete_old_users('some', 'params'
  # User.delay_for(2.weeks).whatever
  # User.delay_until(2.weeks.from_now).whatever
  I strongly recommend avoiding delaying methods on instances. This stores object state in Redis which can get out of date, causing stale data problems.

Class Methods
  Any class method can be delayed via the same methods as above:
  # MyClass.delay.some_method(1, 'bob', true)
  Just remember to keep the method arguments simple, don't pass complex Ruby objects.
=end

=begin
Deployment
To safely shut down Sidekiq, you need to send it the TSTP signal as early as possible in your deploy process
and the TERM signal as late as possible. TSTP tells Sidekiq to stop pulling new work and finish all current work.
TERM tells Sidekiq to exit within N seconds, where N is set by the -t timeout option and defaults to 8.
Using TSTP+TERM in your deploy process gives your jobs the maximum amount of time to finish before exiting.
If any jobs are still running when the timeout is up, Sidekiq will push those jobs back to Redis
so they can be rerun later
=end

=begin
if we want to use the UI we should add the following to your config/routes.rb:
  # require 'sidekiq/web'
  # mount Sidekiq::Web => '/sidekiq'

and If you receive a Forbidden error when trying to submit a form, you do not have a valid session configured.
A valid session is required to prevent CSRF attacks. You must configure the webapp to share the same session with Rails.
Try putting this in your routes.rb after the require:
  # Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
If the above does not work the following can help you debug which portion of rack-protection is causing the problems.
Right after where you set the session, add the following:
  # Sidekiq::Web.use(::Rack::Protection, { use: :authenticity_token, logging: true, message: "Didn't work!" })

Monitoring Queue Latency
Using a custom end-point
If you throw a lot of jobs into the queue, you can get false positives when monitoring the queue backlog. Instead, monitor the queue latency. Queue latency is the difference between when the oldest job was pushed onto the queue versus the current time. This code will check that jobs don't spend more than 30 seconds enqueued. Put this in config/routes.rb:
  require 'sidekiq/api'
  match "queue-latency" => proc { [200, {"Content-Type" => "text/plain"}, [Sidekiq::Queue.new.latency < 30 ? "OK" : "UHOH" ]] }, via: :get
Now when you hit http://example.com/queue-latency, the body of the response will be either 'OK' or 'UHOH'.
=end

=begin
Get all queues
  # Sidekiq::Queue.all
Get a queue
  # Sidekiq::Queue.new # the "default" queue
  # Sidekiq::Queue.new("mailer")
Gets the number of jobs within a queue.
  # Sidekiq::Queue.new.size
Deletes all Jobs in a Queue, by removing the queue.
  # Sidekiq::Queue.new.clear
Deletes jobs within the queue mailer with a jid of 'abcdef1234567890'
  queue = Sidekiq::Queue.new("mailer")
  queue.each do |job|
    job.klass # => 'MyWorker'
    job.args # => [1, 2, 3]
    job.delete if job.jid == 'abcdef1234567890'
  end
Calculate the latency (in seconds) of a queue (now - when the oldest job was enqueued):
  # Sidekiq::Queue.new.latency
Find a job by JID (WARNING: this is very inefficient if your queue is big!)
  # Sidekiq::Queue.new.find_job(somejid)
Scheduled
The scheduled sorted set holds all scheduled jobs in chronologically-sorted order. There's much more in the code,
see sidekiq/api for more detail.
  # ss = Sidekiq::ScheduledSet.new
  # ss.size
  # ss.clear
Allows enumeration of scheduled jobs within Sidekiq. Based on this, you can search/filter for jobs.
Here's an example where I'm selecting all jobs of a certain type and deleting them from the scheduled queue (inefficient).
  # ss = Sidekiq::ScheduledSet.new
  # jobs = ss.select {|retri| retri.klass == 'SomeWorker' }
  # jobs.each(&:delete)
Retries
When a job raises an error, Sidekiq places it in the RetrySet for automatic retry later. Jobs are sorted based on when they will next retry.
  # rs = Sidekiq::RetrySet.new
  # rs.size
  # rs.clear

Allows enumeration of retries within Sidekiq. Based on this, you can search/filter for jobs.
Here's an example where I'm selecting all jobs of a certain type and deleting them from the retry queue (inefficient).
  # query = Sidekiq::RetrySet.new
  # query.select do |job|
  #   job.klass == 'Sidekiq::Extensions::DelayedClass' &&
  #     # For Sidekiq::Extensions (e.g., Foo.delay.bar(*args)),
  #     # the context is serialized to YAML, and must
  #     # be deserialized to get to the original args
  #     ((klass, method, args) = YAML.load(job.args[0])) &&
  #     klass == User &&
  #     method == :setup_new_subscriber
  # end.map(&:delete)

Dead
Like RetrySet and ScheduledSet, the DeadSet holds all jobs considered dead by Sidekiq, ordered by when they died.
It supports the same basic operations as the others.
  # ds = Sidekiq::DeadSet.new
  # ds.size
  # ds.clear

Processes
Sidekiq::ProcessSet gets you access to near real-time (updated every 5 sec) info about the current set of Sidekiq
processes running. You can remotely control the processes also:
  # ps = Sidekiq::ProcessSet.new
  # ps.size # => 2
  # ps.each do |process|
  #   p process['busy']     # => 3
  #   p process['hostname'] # => 'myhost.local'
  #   p process['pid']      # => 16131
  # end
  # ps.each(&:quiet!) # equivalent to the USR1 signal
  # ps.each(&:stop!) # equivalent to the TERM signal
Remote control can be useful in situations where signals are not supported: Windows,
JRuby and the JVM or Heroku for instance.

Stats
Various stats about your Sidekiq installation.
  # stats = Sidekiq::Stats.new
  # stats.processed # => 100
  # stats.failed # => 3
  # stats.queues # => { "default" => 1001, "email" => 50 }
Gets the number of jobs enqueued in all queues (does NOT include retries and scheduled jobs).

  # stats.enqueued # => 5

Stats History
All dates are UTC and history stats are cleared after 5 years.
Get history of failed/processed stats:
  # s = Sidekiq::Stats::History.new(2) # Indicates how many days of data you want starting from today (UTC)
  # s.failed # => { "2012-12-05" => 120, "2012-12-04" => 234 }
  # s.processed # => { "2012-12-05" => 1010, "2012-12-04" => 1500 }
Start from a different date:
  # s = Sidekiq::Stats::History.new( 3, Date.parse("2012-12-3") )
  # s.failed # => { "2012-12-03" => 10, "2012-12-02" => 24, "2012-12-01" => 4 }
  # s.processed # => { "2012-12-03" => 124, "2012-12-02" => 345, "2012-12-01" => 355 }
=end

=begin
Middleware
Sidekiq has a similar notion of middleware to Rack: these are small bits of code that can implement functionality.
Sidekiq breaks middleware into client-side and server-side.
Server-side middleware runs 'around' job processing.
Client-side middleware runs before the pushing of the job to Redis and allows you to modify/stop the job before it gets pushed.
Writing your own middleware

Server-side middleware
Here is a simple server-side middleware which does something upon any exception from any job:

class Sidekiq::Middleware::Server::ErrorLogger
  def call(worker, job, queue)
    begin
      yield
    rescue => ex
      puts ex.message
    end
  end
end
Your middleware will be called with the worker instance which will process the job along with the full Hash which represents the job to process and the name of the queue it was pulled from.

class AcmeCo::MyMiddleware
  def initialize(options=nil)
    # options == { :foo => 1, :bar => 2 }
  end
  def call(worker, msg, queue)
    yield
  end
end
You then register your middleware as part of the chain:

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add AcmeCo::MyMiddleware, :foo => 1, :bar => 2
  end
end
I'd suggest putting this code in config/initializers/sidekiq.rb in your Rails app.

=end
