require 'logger'
require 'json'

module YugiohData 
  module Jobs
    class SynchroniseDatabaseJob 
      def initialize 
        log_path = "log/SynchroniseDatabaseJob-#{Time.now.strftime('%Y%m%d%H%M%S')}.log"
        @logger = Logger.new(log_path)
      end

      def perform
        Dir.glob("out/*.json") do |json_path|
          card_hash = JSON.parse(File.read(json_path))
          card_id = card_hash['CardId']

          card = YugiohData::Entities::Card.find_or_create_by!(CardId: card_id)
          card.Name = card_hash['Name']
          card.CardAttribute = card_hash['Attribute']
          card.Description = card_hash['Description']
          
          if card_hash['Attribute'] == 'SPELL' || card_hash['Attribute'] == 'TRAP'
            card.Property = card_hash['Property']
          else 
            if card_hash.has_key?('LEVEL')
              card.Level = card_hash['LEVEL']
            end

            if card_hash.has_key?('RANK')
              card.Rank = card_hash['RANK']
            end

            if card_hash.has_key?('LINK')
              card.Link = card_hash['LINK']
            end

            if card_hash.has_key?('PendulumScale')
              card.PendulumScale = card_hash['PendulumScale']
              card.PendulumEffect = card_hash['PendulumEffect']
            end

            card.Attack = card_hash['ATK']
            card.Defense = card_hash['DEF']

            card_hash['MonsterTypes'].each do |monster_type_name|
              YugiohData::Entities::MonsterType.find_or_create_by!(CardId: card.CardId, Name: monster_type_name)
            end 


          end

          card_hash['Prints'].each do |card_print_hash|
            card_number = card_print_hash['CardNumber']
            product_name = card_print_hash['ProductName']
            rarity_name = card_print_hash['Rarity']

            product = YugiohData::Entities::Product.find_or_create_by!(Name: product_name)
            rarity = YugiohData::Entities::Rarity.find_or_create_by!(Name: rarity_name)
          
            card_print = YugiohData::Entities::CardPrint.find_or_create_by!(Number: card_number)
            card_print.CardId = card.CardId
            card_print.ProductId = product.ProductId
            card_print.RarityId = rarity.RarityId
            card_print.save!
          end 

          card.save!
          @logger.info("Saved #{card.Name}")
        end
      end
    end
  end
end
