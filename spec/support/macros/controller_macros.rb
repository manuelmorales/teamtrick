module ControllerMacros
  def it_should_require_login
    it "should require login" do
      login_as nil
      do_request

      response.should redirect_to(login_path)
    end
  end

  def it_should_require_admin
    it "should block non-admin users" do
      login_as users(:any)
      do_request
      response.should redirect_to(message_path)
    end
  end

  def it_should_block_users_without_duty_for_current_project
    it "should block users without duty for current_project" do
      user = users(:any)
      raise "You must define @current_project to use this macro, i.e. @current_project = mock_current_project." unless @current_project
      user.duties.with_project(@current_project).first.destroy if user.duties.with_project(@current_project).first
      login_as user.reload

      do_request
      response.should redirect_to(message_path)
    end
  end

  def it_should_render_message_to_users_without_duty_for_current_project
    it "should render message to users without duty for current_project" do
      user = users(:any)
      raise "You must define @current_project to use this macro, i.e. @current_project = mock_current_project." unless @current_project
      user.duties.with_project(@current_project).first.destroy if user.duties.with_project(@current_project).first
      login_as user.reload

      do_request
      response.should render_template("message/index")
    end
  end

  def it_should_block_users_with_role(role_permalink)
    it "should block users with role #{role_permalink}" do
      user = users(:any)
      raise "You must define @current_project to use this macro, i.e. @current_project = mock_current_project." unless @current_project
      @current_project.duties.destroy_all
      Duty.create(:user => user, :project => @current_project, :role => Role.find_by_permalink(role_permalink.to_s))
      login_as users(:any)

      do_request
      response.should redirect_to(message_path)
    end
  end

  def it_should_success_for_users_with_role(role_permalink)
    it "should success for users with role #{role_permalink}" do
      user = users(:any)
      raise "You must define @current_project to use this macro, i.e. @current_project = mock_current_project." unless @current_project
      @current_project.duties.each{|d| d.update_attribute :role, Role.team_member}
      user.duties.with_project(@current_project).first.update_attribute :role, Role.send(role_permalink)
      login_as users(:any)

      do_request
      response_should_be_right
    end
  end

  def it_should_success_for_admins_without_duty
    it "should success for admins without duty" do
      user = users(:admin)
      user.duties.destroy_all
      login_as user

      do_request
      response_should_be_right
    end
  end

  def it_should_set_flash symbol
    it "should set flash #{symbol}" do
      do_request
      flash[symbol].should_not be_nil
    end
  end
end
