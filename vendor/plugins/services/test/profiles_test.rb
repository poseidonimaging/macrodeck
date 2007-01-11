require 'test_helper'
require 'profile'

class ProfilesTest < Test::Unit::TestCase

  fixtures :data_groups    

  def test_constructor_and_desctructor
      # test creating new profile with default metadata
      assert p1 = Profile.new({:creator=>"aaa", :owner=>"bbb"})
      p1.save!
      assert_equal p1.groupingtype, DGROUP_PROFILE
      assert p = Profile.find_by_creator('aaa')
      assert_equal p.owner, "bbb"
      assert p.destroy
  end
end
