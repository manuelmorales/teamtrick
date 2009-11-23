# Matches if an Array is full of objects of a certain class
# examle [1,2,3].should be_full_of(:integers)
Spec::Matchers.define :be_full_of do |expected|
  match do |actual|
    actual.map{|i| i.class.to_s}.uniq.eql? [expected.to_s.camelize.singularize]
  end

  failure_message_for_should do |actual|
    "expected that #{actual.inspect} would be full of #{expected}"
  end
  
  failure_message_for_should_not do |actual|
    "expected that #{actual.inspect} would not be full of #{expected}"
  end
end

