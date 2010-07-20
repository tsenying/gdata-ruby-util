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

class TC_GData_Auth_ClientLogin < Test::Unit::TestCase
  
  include TestHelper
  
  def test_get_token
    client_login = GData::Auth::ClientLogin.new('local')
    source = 'GDataUnitTest'
    assert_nothing_raised do
      token = client_login.get_token(self.get_username(), self.get_password(), source)
    end
  end
  
  def test_specify_account_type
    gp = GData::Client::Maps.new
    gp.source = 'GDataUnitTest'
    assert_nothing_raised do
      token = gp.clientlogin(self.get_username(), self.get_password(), nil, nil, nil, 'GOOGLE')
    end
  end
  
  
end