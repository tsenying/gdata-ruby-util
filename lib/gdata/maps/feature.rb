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
    class Feature < Base
      
      def self.delete(feature)
        edit_url = nil
        if feature.instance_of? String and feature =~ Regexp.new('^http://maps.google.com/maps/feeds/features/[[:xdigit:]]+/[[:xdigit:]]+/full/[[:xdigit:]]+$')
          edit_url = feature
        elsif feature.instance_of? Feature
          edit_url = feature.edit_url
        end
        raise(ArgumentError, 'Edit url cannot be determined') unless edit_url
        
        response = @@client.delete edit_url
      end
      
      def self_url
        feed_entry.at_css('atom|link[rel="self"]')['href']
      end
      
      def edit_url
        feed_entry.at_css('atom|link[rel="edit"]')['href']
      end
      
      def update(atom_entry_xml)
        response = @@client.put edit_url, atom_entry_xml
        feed_entry = response.parse_xml.at_css('atom|entry')
        @feed_entry = feed_entry if feed_entry
        feed_entry ? self : nil
      end
      
      def update!(atom_entry_xml)
        update(atom_entry_xml) || raise('Failed to update feature.')
      end
    end
  end
end