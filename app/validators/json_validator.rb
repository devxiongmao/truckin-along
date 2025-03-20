class JsonValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?

    begin
      unless value.is_a?(Hash) || value.is_a?(Array)
        JSON.parse(value.to_s)
      end
    rescue JSON::ParserError
      record.errors.add(attribute, options[:message] || "is not valid JSON")
    end
  end
end
