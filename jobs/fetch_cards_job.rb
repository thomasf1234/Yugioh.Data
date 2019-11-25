require 'nokogiri'
require 'open-uri'
require 'selenium-webdriver'
require 'logger'
require 'json'
require 'net/http'
require 'uri'
require 'open-uri'
require 'rmagick'

module YugiohData 
  module Jobs
    class FetchCardsJob 
      module BaseUrls
        DB_YUGIOH_CARD_URL = 'https://www.db.yugioh-card.com'
        YGOPRO_URL = 'https://db.ygoprodeck.com'
      end

      def initialize 
        log_path = "log/FetchCardsJob-#{Time.now.strftime('%Y%m%d%H%M%S')}.log"
        @logger = Logger.new(log_path)
      end

      def perform(ygopro_api_version='v5')
        ygopro_all_cards_uri = URI(File.join(BaseUrls::YGOPRO_URL, 'api', ygopro_api_version, 'cardinfo.php'))
        ygopro_raw_cards_json = Net::HTTP.get(ygopro_all_cards_uri)
        ygopro_raw_cards = JSON.parse(ygopro_raw_cards_json)

        options = Selenium::WebDriver::Chrome::Options.new
        options.add_argument('--headless')
        driver = Selenium::WebDriver.for(:chrome, options: options)

        db_yugioh_card_search_url = File.join(BaseUrls::DB_YUGIOH_CARD_URL, 'yugiohdb/card_search.action')
        driver.get(db_yugioh_card_search_url)
        
        click(driver, :id, "privacy-information-cookie-notice-opt-in")
        click(driver, :link, "Search")
        click(driver, :xpath, "(.//*[normalize-space(text()) and normalize-space(.)='View as List'])[1]/following::span[2]")
        click(driver, :link, "Show 100 items per page.")

        has_reached_end = false 

        until has_reached_end do 
          rows = driver.find_element(:class, "box_list").find_elements(:xpath => "*[self::li]")

          rows.each do |row| 
            card_name = row.find_element(:class, 'box_card_name').text.strip  

            # Correct name
            card_name = card_name.gsub(card_name.match(/\(Updated from: .*\)/).to_s, '').strip

            card_request_path = row.find_element(:xpath, './/input[@class="link_value"]').attribute("value")
            card_id = card_request_path.match(/cid=\d+/).to_s.split('=').last.strip.to_i
              
            begin
              card_attribute = row.find_element(:class, 'box_card_attribute').text.strip.upcase
              card_description = row.find_element(:class, 'box_card_text').text.strip   
              
              found_ygopro_raw_card = ygopro_raw_cards.detect {|yrc| yrc['name'].upcase == card_name.upcase }

              if found_ygopro_raw_card.nil?
                @logger.warn("Skipping #{card_name} as YGOPRO card not found")
              else        
                card_passcode = found_ygopro_raw_card['id'].rjust(8, '0')

                outpath = File.join('db/raw', "#{card_passcode}.json")

                if File.exists?(outpath)
                  @logger.warn("Skipping #{card_name}")
                  next
                end

                details_url = File.join(BaseUrls::DB_YUGIOH_CARD_URL, card_request_path)
                details_page = YugiohData::Pages::CardDetailsPage.new(details_url)
                        
                card = {
                  'Name' => card_name,
                  'Attribute' => card_attribute,  
                  'Description' => card_description,
                  'Passcode' => card_passcode,
                  'Prints' => details_page.sets,
                  'Artworks' => []
                }
  
                case card_attribute
                when /(SPELL|TRAP)/
                  card_property = begin
                    row.find_element(:class, 'box_card_effect').text.strip 
                  rescue Selenium::WebDriver::Error::NoSuchElementError 
                    card_property = "Normal"   
                  end
  
                  card['Property'] = card_property
                else
                  card_grade = begin 
                    row.find_element(:class, 'box_card_level_rank').text.strip
                  rescue Selenium::WebDriver::Error::NoSuchElementError
                    row.find_element(:class, 'box_card_linkmarker').text.strip
                  end
  
                  card_grade_type, card_grade_value = card_grade.split(" ").map(&:strip)
  
                  begin 
                    card_pendulum_scale = row.find_element(:class, 'box_card_pen_scale').text.strip.to_i
                    card_pendulum_effect = row.find_element(:class, 'box_card_pen_effect').text.strip
  
                    card['PendulumScale'] = card_pendulum_scale
                    card['PendulumEffect'] = card_pendulum_effect
                  rescue Selenium::WebDriver::Error::NoSuchElementError
                  end
  
                  card_info_species_and_other_item = row.find_element(:class, 'card_info_species_and_other_item').text.strip[1..-2].split('/').map(&:strip)
                  card_atk = row.find_element(:class, 'atk_power').text.strip.split(" ").map(&:strip).last 
                  card_def = row.find_element(:class, 'def_power').text.strip.split(" ").map(&:strip).last 
  
                  card[card_grade_type.upcase] = card_grade_value.to_i
                  card['ATK'] = card_atk
                  card['DEF'] = card_def
                  card['MonsterTypes'] = card_info_species_and_other_item
                end

                found_ygopro_raw_card['card_images'].each do |raw_image_data|
                  image_id = raw_image_data['id']
                  image_url = raw_image_data['image_url']
        
                  image_outpath = File.join('db/raw/artworks', "#{image_id}.png")
        
                  if File.exists?(image_outpath)
                    @logger.warn("Skipping image #{image_id}")
                  else 
                    image_blob = open(image_url).read
                    image = Magick::Image.from_blob(image_blob).first

                    # Crop the specified rectangle out of the img.
                    artwork_image = if card.has_key?('PendulumScale')
                      image.crop(27, 110, 366, 271)
                    else
                      image.crop(49, 111, 323, 323)
                    end
  
                    artwork_image.format = 'PNG'
                    artwork_image.write(image_outpath)

                    @logger.warn("Writing image #{image_id} to #{image_outpath}")

                    md5 = Digest::MD5.file(image_outpath)
                    md5_digest = md5.hexdigest

                    card['Artworks'] << { 'FileName' => File.basename(image_outpath), 'MD5Digest' => md5_digest }
                  end          
                end
  
                File.open(outpath, 'w') { |f| f.write(card.to_json) }
                @logger.info("Writing #{card_name} to #{outpath}")
              end
            rescue => e 
              @logger.error(e.message)
              @logger.error(e.backtrace.join("\n"))
              @logger.info("Retrying CardId #{card_id}, CardName #{card_name}")
              retry 
            end 
          end

          begin
            click(driver, :link, "»")
          rescue Selenium::WebDriver::Error::NoSuchElementError 
            has_reached_end = true
          rescue Selenium::WebDriver::Error::TimeoutError
            has_reached_end = true
          end
        end        
      end

      private
      def click(driver, tag, prop)
        wait = Selenium::WebDriver::Wait.new(:timeout => 60)
        # wait_for_ajax
        element = wait.until{
          tmp_element = driver.find_element(tag, prop)
          tmp_element if tmp_element.enabled? && tmp_element.displayed?
        }
        element.click
      end
    end
  end
end
