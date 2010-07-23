# Copyright (C) 2008 Ying Tsen Hong.
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
    
    # Client class to wrap working with the GMail Atom Feed.
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
          get "#{feeds_url}/maps/default/full"
        else
          # The standard metafeed requests all maps associated with the associated userID
          get "#{feeds_url}/maps/#{userID}/full"
        end
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
        
        # find the map's POST URL in the metafeed
        feed = get_all
        xml_doc = feed.parse_xml
        post_href = xml_doc.at_css("link[rel$='#post']")['href']
        
        result = post post_href, doc.to_s
      end
      
      def delete_map(edit_url)
        raise(ArgumentError, "edit_url cannot be nil") unless edit_url
        self.delete edit_url
      end
    end
  end
end