require File.dirname(__FILE__) + '/../test_helper'
require 'incomplete_controller'

# Re-raise errors caught by the controller.
class IncompleteController; def rescue_action(e) raise e end; end

class IncompleteControllerTest < Test::Unit::TestCase
  def setup
    @controller = IncompleteController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
