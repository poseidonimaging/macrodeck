require File.dirname(__FILE__) + '/../test_helper'
require 'dev_blog_controller'

# Re-raise errors caught by the controller.
class DevBlogController; def rescue_action(e) raise e end; end

class DevBlogControllerTest < Test::Unit::TestCase
  def setup
    @controller = DevBlogController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
