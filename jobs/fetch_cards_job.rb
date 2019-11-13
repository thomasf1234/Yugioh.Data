require 'nokogiri'
require 'open-uri'
require 'selenium-webdriver'
require 'logger'
require 'json'
require 'pp'

module YugiohData 
  module Jobs
    class FetchCardsJob 
      BASE_URL = 'https://www.db.yugioh-card.com'

      def initialize 
        log_path = "log/FetchCardsJob-#{Time.now.strftime('%Y%m%d%H%M%S')}.log"
        @logger = Logger.new(log_path)
        @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
      end

      def perform
        @driver = Selenium::WebDriver.for :chrome
        @base_url = "https://www.katalon.com/"
        @driver.get "https://www.db.yugioh-card.com/yugiohdb/card_search.action"
        
        click(:id, "privacy-information-cookie-notice-opt-in")
        click(:link, "Search")
        click(:xpath, "(.//*[normalize-space(text()) and normalize-space(.)='View as List'])[1]/following::span[2]")
        click(:link, "Show 100 items per page.")

        has_reached_end = false 

        until has_reached_end do 
          rows = @driver.find_element(:class, "box_list").find_elements(:xpath => "*[self::li]")

          rows.each do |row| 
            card_name = row.find_element(:class, 'box_card_name').text.strip        
            card_request_path = row.find_element(:xpath, './/input[@class="link_value"]').attribute("value")
            card_id = card_request_path.match(/cid=\d+/).to_s.split('=').last.strip.to_i
            outpath = "out/#{card_id}.json"

            if File.exists?(outpath)
              @logger.warn("Skipping #{card_name}")
              next
            end
            
            begin
              card_attribute = row.find_element(:class, 'box_card_attribute').text.strip.upcase
              card_description = row.find_element(:class, 'box_card_text').text.strip     

              details_url = File.join(BASE_URL, card_request_path)
              details_page = YugiohData::Pages::CardDetailsPage.new(details_url)

              card = {
                'CardId' => card_id,
                'Name' => card_name,
                'Attribute' => card_attribute,  
                'Description' => card_description,
                'Passcode' => nil,
                'Prints' => details_page.sets   
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

              File.open(outpath, 'w') { |f| f.write(card.to_json) }
              @logger.info("Writing #{card_name} to #{outpath}")
            rescue => e 
              @logger.error(e.message)
              @logger.error(e.backtrace.join("\n"))
              @logger.info("Retrying CardId #{card_id}, CardName #{card_name}")
              retry 
            end 
          end

          begin
            click(:link, "»")
          rescue Selenium::WebDriver::Error::NoSuchElementError 
            has_reached_end = true
          rescue Selenium::WebDriver::Error::TimeoutError
            has_reached_end = true
          end
        end        
      end

      private
      def click(tag,prop)
        # wait_for_ajax
        element = @wait.until{
          tmp_element = @driver.find_element(tag, prop)
          tmp_element if tmp_element.enabled? && tmp_element.displayed?
        }
        element.click
      end
    end
  end
end
