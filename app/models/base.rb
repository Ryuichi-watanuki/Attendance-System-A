class Base < ApplicationRecord
  validates :base_name,  presence: true, length: { maximum: 30 }
end
