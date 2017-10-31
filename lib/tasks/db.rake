require 'highline/import'

namespace :db do

  desc 'Dumps the database to backups'
  task backup: :environment do
    backup_dir = 'tmp/db_backups'
    cmd = nil
    with_config do |app, host, db, user|
      file_name = Time.now.strftime("%Y-%m-%d_%H-%M-%S") + '_' + db + '.' + 'sql' + '.' + 'gz'
      cmd = "pg_dump -U #{user} -v --no-owner -h #{host} -d #{db} | gzip > #{backup_dir}/#{file_name}"
    end
    puts cmd
    exec cmd
  end

  desc 'Restores the database from a backup folder'
  task restore: :environment do
    raise "Nah, I won't restore the production database" if Rails.env.production?
    cmd = nil
    with_config do |app, host, db, user|
      temp_folder = File.join(Rails.root, 'tmp/db_backups')
      files = Dir.glob(File.join(temp_folder, '*.sql.gz')).sort
      if files.empty?
        puts "no files (*.sql.gz) found in #{temp_folder}"
      else
        puts "Too many files in the #{temp_folder}"
        files.each_with_index{|f,i| puts "#{i+1}:#{File.basename(f)}"}
        select_file = ask("Which file? ", Integer) { |q| q.above = 0; q.below = files.size+1 }
        cmd = "gunzip -c #{files[select_file.to_i-1]} | psql #{db}"
      end

      unless cmd.nil?
        Rake::Task["db:drop"].invoke
        Rake::Task["db:create"].invoke
        puts cmd
        exec cmd
      end
    end
  end

  desc 'use faker gem to change recipient_name and recipient_number in fax_record'
  task de_identity: :environment do
     FaxRecord.all.each do |t|
      t.update_attributes(recipient_name: Faker::Name.name)
      t.update_attributes(recipient_number: Faker::Number.number(10))
    end
  end


  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username]
  end

end
