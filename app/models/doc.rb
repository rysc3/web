class Doc < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true

  has_many :photos, dependent: :destroy


  private 
    def create_image_directory 
      FileUtiles.mkdir_p(image_directory)
    end 

    def doc_image_directory
      Rails.root.join("aqpp/assets/images/docs/#{id}")
    end
end
