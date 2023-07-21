class Doc < ApplicationRecord
  belongs_to :doc_type
  has_many_attached :images
end
