require "active_support/all"
require "static_collection/version"

module StaticCollection
  class Base
    # rubocop:disable Metrics/MethodLength
    def self.set_source(source, defaults: {})
      raise "Source must be an array" unless source.is_a?(Array)

      defaults = defaults.stringify_keys
      raise "Source must have at least one value" if source.count <= 0

      values = source.map(&:stringify_keys).map { |s| new(deep_freeze(defaults.merge(s))) }
      instance_variable_set(:@all, values)

      all_attribute_names = values.flat_map { |v| v.attributes.keys }.uniq
      all_attribute_names.each do |attribute_name|
        # Class methods
        define_singleton_method(:"find_by_#{attribute_name}") do |value|
          ActiveSupport::Deprecation.warn(
            "find_by_#{attribute_name} is deprecated for StaticCollection, " \
            "use find_by(#{attribute_name}: [value])",
          )
          all.find { |instance| instance.send(attribute_name) == value }
        end
        define_singleton_method(:"find_all_by_#{attribute_name}") do |value|
          ActiveSupport::Deprecation.warn(
            "find_all_by_#{attribute_name} is deprecated for StaticCollection, " \
            "use where(#{attribute_name}: [value])",
          )
          all.select { |instance| instance.send(attribute_name) == value }
        end

        # Instance methods
        send(:define_method, attribute_name) { attributes[attribute_name] }
        send(:define_method, "#{attribute_name}?") {
          attributes[attribute_name] if attributes.key?(attribute_name)
        }
      end
    end
    # rubocop:enable Metrics/MethodLength

    class << self
      private

      def deep_freeze(obj)
        case obj
        when Hash
          obj.each_with_object({}) do |(key, value), acc|
            acc[deep_freeze(key)] = deep_freeze(value)
          end.freeze
        when Array
          obj.map do |value|
            deep_freeze(value)
          end.freeze
        when Symbol, Integer, NilClass
          obj
        else
          obj.freeze
        end
      end
    end

    def self.find_by(opts)
      all.find { |instance| opts.all? { |k, v| instance.send(k) == v } }
    end

    def self.where(opts)
      all.select { |instance| opts.all? { |k, v| instance.send(k) == v } }
    end

    def self.all
      instance_variable_get(:@all)
    end

    def self.count
      all.size
    end
    singleton_class.send(:alias_method, :size, :count)

    attr_reader :attributes

    def initialize(attributes = {})
      @attributes = attributes
    end

    def as_json(options = {})
      attributes.as_json(options)
    end
  end
end
