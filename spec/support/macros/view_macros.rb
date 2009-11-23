module ViewMacros
  def it_should_have_link_to p, text = nil
    it "should have link to path #{p}#{text && " named "+text}" do
      render
      response.should have_tag("a[href=?]", eval(p), text)
    end
  end

  def it_should_not_have_link_to p, text = nil
    it "should not have link to path #{p}#{text && " named "+text}" do
      render
      response.should_not have_tag("a[href=?]", eval(p), text)
    end
  end

  def it_should_render_successfully
    it "should render successfully" do
      render
      response.should be_success
    end
  end

  def it_should_render_partial partial
    it "should render partial #{partial}" do
      render
      response.should have_text(/Beginning of #{partial}/)
    end
  end
end
