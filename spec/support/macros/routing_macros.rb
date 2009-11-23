module RoutingMacros
  def it_should_map_path path_name, path
    it "should map \"#{path_name}\" to \"#{path}\"" do
      eval(path_name).should ==  path
    end
  end
end
