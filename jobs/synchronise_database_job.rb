require 'logger'
require 'json'
# require 'rmagick'

module YugiohData 
  module Jobs
    class SynchroniseDatabaseJob 
      def initialize 
        log_path = "log/SynchroniseDatabaseJob-#{Time.now.strftime('%Y%m%d%H%M%S')}.log"
        @logger = Logger.new(log_path)
      end

      def perform
        data_path = 'db/raw'

        Dir.glob(File.join('db/raw', '*.json')) do |data_json_path|
          card_hash = JSON.parse(File.read(data_json_path))
          card_id = card_hash['Passcode'].to_i # will removing leading zeros

          card_spec = if YugiohData::Entities::CardSpec.exists?(CardId: card_id)
            YugiohData::Entities::CardSpec.find_by(CardId: card_id)    
          else 
            YugiohData::Entities::CardSpec.new(CardId: card_id)
          end

          card_spec.Name = card_hash['Name']
          card_spec.CardAttribute = card_hash['Attribute']
          card_spec.Description = card_hash['Description']
          
          if card_hash['Attribute'] == 'SPELL' || card_hash['Attribute'] == 'TRAP'
            card_spec.Property = card_hash['Property']
          else 
            if card_hash.has_key?('LEVEL')
              card_spec.Level = card_hash['LEVEL']
            end

            if card_hash.has_key?('RANK')
              card_spec.Rank = card_hash['RANK']
            end

            if card_hash.has_key?('LINK')
              card_spec.Link = card_hash['LINK']
            end

            if card_hash.has_key?('PendulumScale')
              card_spec.PendulumScale = card_hash['PendulumScale']
              card_spec.PendulumEffect = card_hash['PendulumEffect']
            end

            card_spec.Attack = card_hash['ATK']
            card_spec.Defense = card_hash['DEF']

            card_hash['MonsterTypes'].each do |monster_type_name|
              YugiohData::Entities::MonsterType.find_or_create_by!(CardId: card_spec.CardId, Name: monster_type_name)
            end 
          end

          card_hash['Prints'].each do |card_set_hash|
            set_code = card_set_hash['SetCode']
            set_name = card_set_hash['SetName']
            rarity_name = card_set_hash['RarityName']

            abbreviation = set_code.split('-').first

            card_set = YugiohData::Entities::CardSet.find_or_create_by!(Name: set_name, Abbreviation: abbreviation)
            rarity = YugiohData::Entities::Rarity.find_or_create_by!(Name: rarity_name)
          
            card_print = if YugiohData::Entities::CardPrint.exists?(SetCode: set_code)
              YugiohData::Entities::CardPrint.find_by(SetCode: set_code)    
            else 
              YugiohData::Entities::CardPrint.new(SetCode: set_code)
            end

            card_print.CardId = card_spec.CardId
            card_print.CardSetId = card_set.CardSetId
            card_print.RarityId = rarity.RarityId
            card_print.save!
          end 

          artworks_dir = File.join(data_path, 'artworks')

          card_hash['Artworks'].each_with_index do |artwork_hash, artwork_index|
            image_path = File.join(artworks_dir, artwork_hash['FileName'])
            image_md5 = artwork_hash['MD5Digest']

            image = Magick::Image.read(image_path).first
            image.format = 'PNG'

            image_blob = image.to_blob

            if YugiohData::Entities::Artwork.exists?(MD5: image_md5)
              @logger.info("Skipping artwork #{card_spec.Name} : #{image_path}")

              next              
            end

            artwork = YugiohData::Entities::Artwork.new

            artwork.Image = image_blob
            artwork.MD5 = image_md5
            artwork.CardId = card_spec.CardId
            artwork.Alternate = artwork_index == 0 ? false : true 

            @logger.info("Saved artwork #{card_spec.Name} : #{image_path}")
            artwork.save!

            #TODO : Unique check on image per cardid
          end

          card_spec.save!
          @logger.info("Saved #{card_spec.Name}")
        end
      end
    end
  end
end
