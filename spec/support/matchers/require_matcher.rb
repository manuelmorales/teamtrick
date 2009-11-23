# Matches if the attribute is required by the model
Spec::Matchers.define :need do |attr|
  match do |model|
    model.send("#{attr.to_s}=".to_sym, nil)
    !model.valid?
  end

  failure_message_for_should do |model|
    "expected that #{model.class.to_s} would require #{attr}"
  end
  
  failure_message_for_should_not do |model|
    "expected that #{model.class.to_s} would not require #{attr}"
  end
end

