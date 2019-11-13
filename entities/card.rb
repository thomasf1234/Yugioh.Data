module YugiohData
  module Entities
    class Card < ActiveRecord::Base
      self.table_name = 'Card'
    end
  end
end
