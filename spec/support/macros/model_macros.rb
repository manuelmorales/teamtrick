module ModelMacros
  def it_should_be_valid_with attrs
    it "should be valid with #{sentence_of attrs}" do
      attrs.keys.each do |a|
        @record.send(a).should_not be_nil
      end
      @record.should be_valid
    end
  end

  def it_should_not_be_valid_without required_values
    required_values.keys.each do |a|
      it "should not be valid without #{a}" do
        @record.should need(a)
      end
    end
  end
end
