module ApplicationHelper
  def mock_current_project
    p = projects(:project_0)
    controller.stub! :current_project => p
    p
  end

  def response_should_be_right
    if response.request.method == :get
      response.should be_success
    else
      response.should redirect_to(:action => :index)
    end

    response.should_not render_template("message/index")
  end
end
