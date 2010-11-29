# Copyright (C) 2008 Google Inc.
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

class TC_GData_Client_Maps < Test::Unit::TestCase
  include TestHelper
  extend  TestHelper::ClassMethods
  
  def self.startup
    @@client = GData::Client::Maps.new
    @@client.clientlogin(self.get_username, self.get_password)
    @@test_map = @@client.create_map("GData::Client::Maps TestSuiteMap", "Test Suite Map.")
  end
  
  def self.shutdown
    @@client.delete_map(@@test_map.parse_xml.at_css("link[rel='edit']")['href'])
    @@client = nil
  end
  
  def setup
  end
  
  def teardown
  end
  
  def test_get_token
    client_login = GData::Auth::ClientLogin.new('local')
    source = 'GDataUnitTest'
    assert_nothing_raised do
      token = client_login.get_token(self.get_username(), self.get_password(), source)
    end
  end
  
  def test_specify_account_type
    gp = GData::Client::Maps.new
    assert_nothing_raised do
      token = gp.clientlogin(self.get_username(), self.get_password(), nil, nil, nil, 'GOOGLE')
    end
  end
  
  def test_get_all   
    response = @@client.get_all
    self.assert_equal(200, response.status_code, 'Must not be a redirect.')
    feed = response.to_xml
    self.assert_not_nil(feed, 'feed can not be nil')
    
    xml_doc = response.parse_xml
    node_set = xml_doc.css('feed id')
    assert_not_equal 0, node_set.size
    id_content = node_set[0].content
    
    # get_all by userID
    re = Regexp.new("#{@@client.feeds_url}/maps/(\\d+)")
    match = re.match id_content
    assert_not_nil match, 'should be able to get match on userID from id element'
    assert_not_nil match[1], 'should be able to get userID from id element'
    
    userID = match[1]
    response = @@client.get_all userID
    xml_doc = response.parse_xml
    node_set = xml_doc.css('feed id')
    assert_not_equal 0, node_set.size
    id_content = node_set[0].content
    
    match = re.match id_content
    assert_equal userID, match[1]

    post_href = xml_doc.at_css("link[rel$='#post']")['href']
    re = Regexp.new("#{@@client.feeds_url}/maps/(\\d+)/full")
    assert re =~ post_href
    # puts "post_href=#{post_href}"
  end
  
  def test_create
    response = @@client.create_map("GData::Client::Maps Test", "Test Map.")
    assert_equal 201, response.status_code
    xml_doc = response.parse_xml
    assert_equal "GData::Client::Maps Test", xml_doc.at_css('entry title').content
    
    # clean up
    response = @@client.delete_map(xml_doc.at_css("link[rel='edit']")['href'])
    assert_equal 200, response.status_code
  end
  
  def test_create_feature
    response = @@client.create_feature(@@test_map, 'title_str', 'name_str', 'description_str', 
      coordinates_hash = {:longitude => '-105.27', :latitude => '40.015', :elevation => '0.0'})
    assert_equal 201, response.status_code
    puts response.body
    assert_equal 'title_str', response.parse_xml.at_css('atom|entry Placemark name').content
  end
  
  def test_metafeed_post_url
    result = @@client.metafeed_post_url
    assert_equal "#{@@client.feeds_url}/maps/#{@@client.userID}/full", result
  end
  
end