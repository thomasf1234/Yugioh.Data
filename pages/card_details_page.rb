require 'open-uri'
require 'nokogiri'

module YugiohData 
  module Pages 
    class CardDetailsPage
      attr_reader :sets
      
      def initialize(url)
        @html = Nokogiri::HTML(open(url))

        @sets = []
        set_rows = @html.xpath('//div[@id="pack_list"]').xpath('.//tr[@class="row"]') 
        
        set_rows.each do |set_row|
          set_columns = set_row.xpath('.//td')

          card_number = set_columns[1].text.strip 
          set_name = set_columns[2].text.strip.upcase
          rarity_img = set_columns.last.xpath('.//img').first

          rarity = rarity_img.nil? ? "Common" : rarity_img.attribute('alt').value.strip

          set = { 'SetCode' => card_number,  'SetName' => set_name, 'RarityName' => rarity }
          @sets << set
        end
      end
    end
  end
end