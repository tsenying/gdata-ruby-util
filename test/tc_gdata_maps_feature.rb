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

class TC_GData_Maps_Feature < Test::Unit::TestCase
  include TestHelper
  extend  TestHelper::ClassMethods
  
  def self.startup
    @@client = GData::Client::Maps.new
    @@client.clientlogin(self.get_username, self.get_password)
    @@test_map = GData::Maps::Map.create("GData::Maps::Feature", "Test Case Map.")
    @@test_feature = @@test_map.create_feature('title_str', 'name_str', 'description_str', 
      coordinates_hash = {:longitude => '-105.27', :latitude => '40.015', :elevation => '0.0'})
  end
  
  def self.shutdown
    response = GData::Maps::Map.delete(@@test_map.at_css("link[rel='edit']")['href'])
    @@test_map = nil
    @@client = nil
  end
  
  def setup
    @test_feature = @@test_map.create_feature('feature title', 'feature name', 'feature description', 
      coordinates_hash = {:longitude => '-105.271', :latitude => '40.016', :elevation => '1000.0'})
  end
  
  def teardown
    GData::Maps::Feature.delete(@test_feature)
  rescue GData::Client::UnknownError
  end
  
  # def test_create_feature
  #   feature = @@test_map.create_feature('title_str', 'name_str', 'description_str', 
  #     coordinates_hash = {:longitude => '-105.27', :latitude => '40.015', :elevation => '0.0'})
  #   assert_not_nil feature
  #   puts "\n\n!!!!!debug=#{feature.feed_entry}"
  #   assert_equal 'name_str', feature.at_css('atom|content Placemark name').content
  # end
  
  def test_edit_url
    edit_url = @@test_feature.edit_url
    re = Regexp.new('http://maps.google.com/maps/feeds/features/[[:xdigit:]]+/[[:xdigit:]]+/full/[[:xdigit:]]+')
    assert re =~ edit_url
  end
  
  def test_self_url
    self_url = @@test_feature.self_url
    re = Regexp.new('http://maps.google.com/maps/feeds/features/[[:xdigit:]]+/[[:xdigit:]]+/full/[[:xdigit:]]+')
    assert re =~ self_url
  end
  
  def test_update_feature 
    entry = @@test_feature.feed_entry.clone
    coordinates = entry.at_css('Placemark Point coordinates')
    coordinates.content = '-105.66,40.015,1000.0'
    puts "entry=#{entry.to_s}"
    updated_feature = @@test_feature.update entry.to_s
    assert_not_nil updated_feature
    assert updated_feature.at_css('Placemark Point coordinates').content = '-105.66,40.015,1000.0'
  end
  
  def test_delete_feature
    response = GData::Maps::Feature.delete(@test_feature)
    assert_equal 200, response.status_code
  end
  
  def test_find_features
  end
  
  def test_find_features_by_bounding_box
  end
  
end