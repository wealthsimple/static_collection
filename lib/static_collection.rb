require "active_support/all"
require "static_collection/version"

module StaticCollection
  class Base
    def self.set_source(source, defaults: {})
      raise "Source must be an array" unless source.is_a?(Array)

      instance_variable_set(:@defaults, defaults.stringify_keys)
      instance_variable_set(:@source, source.map(&:stringify_keys))
      raise "Source must have at least one value" unless count > 0

      all.first.attributes.each do |attribute_name, attribute_value|
        # Class methods
        define_singleton_method("find_by_#{attribute_name}") do |value|
          ActiveSupport::Deprecation.warn(
            "find_by_#{attribute_name} is deprecated for StaticCollection, " \
            "use find_by(#{attribute_name}: [value])",
          )
          all.find { |instance| instance.send(attribute_name) == value }
        end
        define_singleton_method("find_all_by_#{attribute_name}") do |value|
          ActiveSupport::Deprecation.warn(
            "find_all_by_#{attribute_name} is deprecated for StaticCollection, " \
            "use where(#{attribute_name}: [value])",
          )
          all.select { |instance| instance.send(attribute_name) == value }
        end

        # Instance methods
        send(:define_method, attribute_name) { attributes[attribute_name] }
        next unless attribute_value.is_a?(TrueClass) || attribute_value.is_a?(FalseClass)

        send(:define_method, "#{attribute_name}?") {
          attributes[attribute_name]
        }
      end
    end

    def self.find_by(opts)
      all.find { |instance| opts.all? { |k, v| instance.send(k) == v } }
    end

    def self.where(opts)
      all.select { |instance| opts.all? { |k, v| instance.send(k) == v } }
    end

    def self.all
      defaults = instance_variable_get(:@defaults)
      instance_variable_get(:@source).map { |s| new(defaults.merge(s)) }
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
