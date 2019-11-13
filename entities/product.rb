module YugiohData
  module Entities
    class Product < ActiveRecord::Base
      self.table_name = 'Product'
    end
  end
end
