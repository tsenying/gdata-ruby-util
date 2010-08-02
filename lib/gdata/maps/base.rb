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
    class Base
      # entry element from metafeed or the result from creating a map
      # instance of Nokogiri::XML::Node
      attr_accessor :feed_entry
    
      @@client = nil
      def self.establish_connection
        unless @@client
          if defined? Rails
            gdata_maps_config = "gdata_maps_#{RAILS_ENV}"
            # Rails.root is not yet defined when Bundler calls this, assume in Rails.root directory
            configurations = YAML.load_file(('config/gdata.yml').to_s)
            @@config = configurations[gdata_maps_config]
          else
            gdata_maps_config = "gdata_maps_" + (ENV['DB'] || "development")
            configurations = YAML.load_file(File.join(File.dirname(__FILE__), '../../../config/gdata.yml'))
            @@config = configurations[gdata_maps_config]
          end
          @@client = GData::Client::Maps.new
          puts "username=#{@@config['username']}, password=#{@@config['password']}"
          @@client.clientlogin(@@config['username'], @@config['password'])
        end
      end
      establish_connection()
      
      def self.config
        @@config
      end
      
      def initialize(entry)
        @feed_entry = entry
      end
      
      def method_missing(method_id, args=nil)
        @feed_entry.send(method_id, *args)
      end
    end
  end
end