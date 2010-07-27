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

$:.unshift(File.dirname(__FILE__))
require 'test_helper'

class TC_GData_Maps_Map < Test::Unit::TestCase
  include TestHelper
  extend  TestHelper::ClassMethods
  
  def self.startup
    @@client = GData::Client::Maps.new
    @@client.clientlogin(self.get_username, self.get_password)
    @@test_map = GData::Maps::Map.create("GData::Maps::Map", "Test Case Map.")
    @@test_feature = @@test_map.create_feature('Feature Title', 'Feature Name', 'Feature Description', 
      coordinates_hash = {:longitude => '-105.2701', :latitude => '40.0151', :elevation => '1000.0'})
  end
  
  def self.shutdown
    response = GData::Maps::Map.delete(@@test_map.at_css("link[rel='edit']")['href'])
    @@test_map = nil
    @@client = nil
  end
  
  def setup
  end
  
  def teardown
  end
  
  def test_create_and_delete_map
    map = GData::Maps::Map.create("GData::Maps::Map::Map#create Test", "Test test_create_and_delete_map Map.")
    assert_not_nil map
    assert_equal "GData::Maps::Map::Map#create Test", map.at_css('title').content
    
    # clean up
    response = GData::Maps::Map.delete(map.at_css("link[rel='edit']")['href'])
    assert_equal 200, response.status_code
  end
  
  def test_find_by_title
    map = GData::Maps::Map.find_by_title("GData::Maps::Map")
    assert_not_nil map
    assert_equal "GData::Maps::Map", map.at_css('title').content
  end
  
  def test_create_feature
    feature = @@test_map.create_feature('title_str', 'name_str', 'description_str', 
      coordinates_hash = {:longitude => '-105.27', :latitude => '40.015', :elevation => '0.0'})
    assert_not_nil feature
    puts "\n\n!!!!!debug=#{feature.feed_entry}"
    assert_equal 'name_str', feature.at_css('atom|content Placemark name').content
  end
  
  def test_update_feature 
  end
  
  def test_delete_feature
  end
  
  def test_find_features
  end
  
  def test_find_features_by_bounding_box
    # box=west,south,east,north, e.g. box=-109,37,-102,41
    # box = 'box=-105.3,40.0,-105.0,40.1'
    box = 'box=-109,37,-102,41'
    response = @@test_map.find_features(box)
    puts "response=#{response.parse_xml}"
    entries = response.parse_xml.css('atom|entry')
    assert_not_equal 0, entries.size
    assert entries.find { |entry| entry.at_css('Placemark name').content == 'Feature Name'}
  end
  
  def test_find_features_by_radius
    radius = 'radius=10000&lng=-105.27&lat=40.015'
    response = @@test_map.find_features(radius)
    puts "response=#{response.parse_xml}"
    entries = response.parse_xml.css('atom|entry')
    assert_not_equal 0, entries.size
    assert entries.find { |entry| entry.at_css('Placemark name').content == 'Feature Name'}
  end
end