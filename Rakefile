# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

task 'assets:precompile' do
  if ENV['SKIP_ASSET_COMPILE']
    puts "Skipping assets:precompile because SKIP_ASSET_COMPILE is set"
  else
    Rake::Task['assets:precompile'].invoke
  end
end
