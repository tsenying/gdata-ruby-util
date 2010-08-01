# Copyright (C) 2010 Ying Tsen Hong.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module GData
  module Client
    
    # Client class to wrap working with the Maps Atom Feed.
    class Maps < Base
      
      attr_accessor :feeds_url
      
      def initialize(options = {})
        options[:clientlogin_service] ||= 'local'
        options[:authsub_scope] ||= 'http://maps.google.com/maps/feeds'
        options[:feeds_url] ||= 'http://maps.google.com/maps/feeds'
        super(options)
      end
      
      def get_all(userID = nil)
        unless userID
          # The default feed requests all maps associated with the authenticated user
          unless @metafeed
            @metafeed = get "#{feeds_url}/maps/default/full"
          end
          @metafeed
        else
          # The standard metafeed requests all maps associated with the associated userID
          get "#{feeds_url}/maps/#{userID}/full"
        end
      end
      
      def userID
        unless @userID
          id_content = get_all.parse_xml.at_css('feed id').content
          re = Regexp.new("#{feeds_url}/maps/([[:xdigit:]]+)")
          match = re.match id_content
          @userID = match[1]
        end
        @userID
      end
      
      def create_map(title_str, summary_str = '')
        raise(ArgumentError, "title cannot be nil") unless title_str
        
        # create the map entry; looks like:
        # <entry xmlns="http://www.w3.org/2005/Atom">
        #   <title>Bike Ride, 10 Years Old</title>
        #   <summary></summary>
        # </entry>
        doc = Nokogiri::XML::Document.new
        entry = Nokogiri::XML::Node.new "entry", doc
        entry['xmlns'] = "http://www.w3.org/2005/Atom"
        title = Nokogiri::XML::Node.new "title", doc
        title.content = title_str
        entry.add_child(title)
        summary = Nokogiri::XML::Node.new 'summary', doc
        summary.content = summary_str
        entry.add_child(summary)
        doc.add_child(entry)
        
        result = post metafeed_post_url, doc.to_s
      end
      
      def delete_map(edit_url)
        raise(ArgumentError, "edit_url cannot be nil") unless edit_url
        self.delete edit_url
      end
      
      # map - GData::Http::Response instance from create_map
      # feature - xml atom:entry for feature
      # returns - instance of GData::Http::Response
      def create_feature(map, title_str, name_str, description_str = '', 
                         coordinates_hash = {:longitude => nil, :latitude => nil, :elevation => '0.0'})
        post_url = post_url(map)
        puts "post_url=#{post_url}"
        result = post post_url, create_placemark_kml(title_str, name_str, description_str, coordinates_hash)
      end
      
      # find the map's POST URL in the metafeed
      def metafeed_post_url
        unless @metafeed_post_url
          @metafeed_post_url = get_all.parse_xml.at_css("link[rel$='#post']")['href']
        end
        @metafeed_post_url
      end
      
      protected
      
      # map is the 'entry' element from the maps metafeed or returned from a map create call
      def feature_feed_url(map)
        puts map.parse_xml.at_css("content")['src']
        map.parse_xml.at_css("content")['src']
      end
      
      def post_url(map)
        response = get feature_feed_url(map)
        puts response.body
        puts response.parse_xml.at_css("atom|link[rel$='#post']")['href']
        post_href = response.parse_xml.at_css("atom|link[rel$='#post']")['href']
      end
      
      def edit_url(map)
        map.parse_xml.at_css("link[rel='edit']")['href']
      end
      
      def create_placemark_kml(title_str, name_str, description_str = '', 
                               coordinates_hash = {:longitude => nil, :latitude => nil, :elevation => '0.0'})
        raise(ArgumentError, "title cannot be nil") unless title_str
        raise(ArgumentError, "name cannot be nil") unless name_str
        raise(ArgumentError, "longitude cannot be nil") unless coordinates_hash[:longitude]
        raise(ArgumentError, "latitude cannot be nil") unless coordinates_hash[:latitude]
        raise(ArgumentError, "invalid longidtude #{coordinates_hash[:longitude]}") unless coordinates_hash[:longitude] =~ /^-?((([1]?[0-7][0-9]|[1-9]?[0-9])\.{1}\d{1,6}$)|[1]?[1-8][0]\.{1}0{1,6}$)/
        raise(ArgumentError, "invalid latidtude #{coordinates_hash[:latitude]}") unless coordinates_hash[:latitude] =~ /^-?([1-8]?[0-9]\.{1}\d{1,6}$|90\.{1}0{1,6}$)/
        
        doc = Nokogiri::XML::Document.new
        entry = Nokogiri::XML::Node.new "atom:entry", doc
        entry['xmlns'] = 'http://www.opengis.net/kml/2.2'
        entry['xmlns:atom'] = "http://www.w3.org/2005/Atom"
        
        title = Nokogiri::XML::Node.new "atom:title", doc
        title['type'] = 'text'
        title.content = title_str
        entry.add_child title
        
        content = Nokogiri::XML::Node.new "atom:content", doc
        content['type'] = 'application/vnd.google-earth.kml+xml'
        entry.add_child content
        
        placemark = Nokogiri::XML::Node.new "Placemark", doc
        content.add_child placemark
        
        name = Nokogiri::XML::Node.new 'name', doc
        name.content = name_str
        placemark.add_child name
        
        description = Nokogiri::XML::Node.new 'description', doc
        description.content = description_str
        placemark.add_child description
        
        point = Nokogiri::XML::Node.new 'Point', doc
        placemark.add_child point
        
        coordinates = Nokogiri::XML::Node.new 'coordinates', doc
        coordinates.content = "#{coordinates_hash[:longitude]},#{coordinates_hash[:latitude]},#{coordinates_hash[:elevation]}"
        point.add_child coordinates
        
        entry.to_s
      end
    end
  end
end