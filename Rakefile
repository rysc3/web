# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"
require 'active_storage'

Rails.application.load_tasks

namespace :active_storage do
  task :uploadblobs, [:image_path, :doc_id] do |_, args|
    image_path = args[:image_path]
    doc_id = args[:doc_id]

    blob = ActiveStorage::Blob.create_from_file(image_path)
    doc = Doc.find(doc_id)
    doc.images.attach(blob)
  end
end