module MultiJson
  module ConvertibleHashKeys
    private

    def symbolize_keys(object)
      prepare_object(object) do |key|
        key.respond_to?(:to_sym) ? key.to_sym : key
      end
    end

    def stringify_keys(object)
      prepare_object(object) do |key|
        key.respond_to?(:to_s) ? key.to_s : key
      end
    end

    def prepare_object(object, &key_modifier)
      return object unless block_given?
      case object
      when Array
        object.map do |value|
          prepare_object(value, &key_modifier)
        end
      when Hash
        object.inject({}) do |result, (key, value)|
          new_key   = key_modifier.call(key)
          new_value = prepare_object(value, &key_modifier)
          result.merge! new_key => new_value
        end
      when String, Numeric, true, false, nil
        object
      else
        if object.respond_to?(:to_json)
          object
        elsif object.respond_to?(:to_s)
          object.to_s
        else
          object
        end
      end
    end
  end
end
