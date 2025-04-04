class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  before_save :ensure_slug_is_unique

  def ensure_slug_is_unique
    if Room.exists?(slug: slug)
      errors.add(:slug, 'has already been taken')
      throw(:abort) 
    end
  end
end
