require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  describe "link_to_or_nil" do
    describe "without passing it a block" do
      it "should return nil when condition is false" do
        link_to_or_nil( false, "Name", "some/path").should be_nil
      end

      it "should return the link if condition is true" do
        link_to_or_nil( true, "Name", "some/path").should have_tag('a[href=?]', "some/path", "Name")
      end

      it "should work with :confirm => 'Message' too" do
        text = link_to_or_nil( true, "Name", "some/path", :confirm => 'Are you sure?', :method => :delete)
        text.should == link_to( "Name", "some/path", :confirm => 'Are you sure?', :method => :delete)
      end
    end

    describe "passing it a block" do
      it "should return the result of the block when condition is false" do
        link_to_or_nil( false, "Name", "some/path"){"block content"}.should == "block content"
      end

      it "should return the link if condition is true" do
        link_to_or_nil( true, "Name", "some/path"){"block content"}.should have_tag('a[href=?]', "some/path", "Name")
      end
    end
  end

  describe "separate" do
    before :each do
      @link_a = link_to("A", "/")
      @link_b = link_to("B", "/")
    end

    it "should return arguments joined with a separator" do
      separate([@link_a, @link_b]).should ==  @link_a + " | " + @link_b
    end
  end
end
