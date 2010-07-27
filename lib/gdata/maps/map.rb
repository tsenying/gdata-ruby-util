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
  module Maps
    class Map < Base
    
      # returns array of Maps
      def self.get_all(userID = nil)
        unless userID
          # The default feed requests all maps associated with the authenticated user
          response = @@client.get "#{@@client.feeds_url}/maps/default/full"
        else
          # The standard metafeed requests all maps associated with the associated userID
          response = @@client.get "#{@@client.feeds_url}/maps/#{userID}/full"
        end
        response.parse_xml.css('entry').map do |entry|
          Map.new(entry)
        end
      end
      
      def self.find_by_title(title)
        get_all.find{ |map| map.at_css('title').content == title }
      end
    
      # returns instance of Map
      def self.create(title_str, summary_str = '')
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
      
        response = @@client.post @@client.metafeed_post_url, doc.to_s
        feed_entry = response.parse_xml.at_css('entry')
        feed_entry ? Map.new(feed_entry) : nil
      end
    
      def self.delete(edit_url)
        raise(ArgumentError, "edit_url cannot be nil") unless edit_url
        @@client.delete edit_url
      end
      
      def feature_feed_url
        feed_entry.at_css("content")['src']
      end
      
      def search_feed_url
        feature_feed_url#.sub!(/full/, 'snippet')
      end
    
      def post_url
        response = @@client.get feature_feed_url
        post_href = response.parse_xml.at_css("atom|link[rel$='#post']")['href']
      
        response = @@client.get feature_feed_url
        post_url = response.parse_xml.at_css("atom|link[rel$='#post']")['href']
        post_url
      end
    
      def edit_url
        feed_entry.at_css("link[rel='edit']")['href']
      end
      
      # feature - xml atom:entry for feature
      # returns - instance of GData::Http::Response
      def create_feature(title_str, name_str, description_str = '', 
                         coordinates_hash = {:longitude => nil, :latitude => nil, :elevation => '0.0'})
        response = @@client.post post_url, create_placemark_kml(title_str, name_str, description_str, coordinates_hash)
        # Feature.new response.parse_xml.at_css('atom|entry')
        feed_entry = response.parse_xml.at_css('atom|entry')
        feed_entry ? Feature.new(feed_entry) : nil
      end
      
      # The following search parameters are currently supported:
      # [mq] implements a maps query, passing an array of one or more attribute matches. (See Attribute Search below.)
      # [box] specifies the bounding box of a geographic area over which to implement the search. The box parameter takes four comma-separate arguments in the order west,south,east,north. (See Spatial Search below.)
      # [lat] and lng specifies a center point from which to implement the search. This location is used in conjunction with the radius argument to specify a circular area over which to search. (See Spatial Search below.)
      # [radius] specifies the radius, in meters, from a center point (specified in the lat and lng parameters), over which to implement a search. (See Spatial Search below.)
      # [sortby] indicates that the results should be returned sorted by a passed constraint. Currently, only sortby=distance is supported. (See Sorting Searches below.)
      def find_features(query)
        puts "find_features:url =#{search_feed_url}?#{CGI.escape query}"
        response = @@client.get "#{search_feed_url}?#{CGI.escape query}"
      end
      
      protected
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

        # empty style element works around broken API issue
        # http://groups.google.com/group/google-maps-data-api/browse_thread/thread/2bd1ff4b1e2a8274
        style = Nokogiri::XML::Node.new 'Style', doc
        placemark.add_child style
        
        entry.to_s
      end
    end
  end
end