require "active_support/all"
require "static_collection/version"

module StaticCollection
  class Base
    def self.set_source(source, defaults: {})
      raise "Source must be an array"  unless source.is_a?(Array)
      self.class_variable_set(:@@defaults, defaults.stringify_keys)
      self.class_variable_set(:@@source, source.map(&:stringify_keys))
      raise "Source must have at least one value"  unless count > 0

      all.first.attributes.each do |attribute_name, attribute_value|
        # Class methods
        self.define_singleton_method("find_by_#{attribute_name}") do |value|
          ActiveSupport::Deprecation.warn("find_by_#{attribute_name} is deprecated for StaticCollection, use find_by(#{attribute_name}: [value])")
          all.find { |instance| instance.send(attribute_name) == value }
        end
        self.define_singleton_method("find_all_by_#{attribute_name}") do |value|
          ActiveSupport::Deprecation.warn("find_all_by_#{attribute_name} is deprecated for StaticCollection, use where(#{attribute_name}: [value])")
          all.select { |instance| instance.send(attribute_name) == value }
        end

        # Instance methods
        self.send(:define_method, attribute_name) { attributes[attribute_name] }
        self.send(:define_method, "#{attribute_name}?") { attributes[attribute_name] }  if attribute_value.is_a?(TrueClass) || attribute_value.is_a?(FalseClass)
      end
    end

    def self.find_by(opts)
      all.find { |instance| opts.all? { |k, v| instance.send(k) == v } }
    end

    def self.where(opts)
      all.select { |instance| opts.all? { |k, v| instance.send(k) == v } }
    end

    def self.all
      defaults = self.class_variable_get(:@@defaults)
      self.class_variable_get(:@@source).map { |s| self.new(defaults.merge(s)) }
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
