class Photo < ApplicationRecord 
  belongs_to :doc
  has_one_attached :image
end