require File.dirname(__FILE__) + '/../test_helper'
require 'places_controller'

# Re-raise errors caught by the controller.
class PlacesController; def rescue_action(e) raise e end; end

class PlacesControllerTest < Test::Unit::TestCase
  def setup
    @controller = PlacesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
