module RspecAttributesAccessible
  class AccessibleAttributes

    def initialize(*attributes)
      @attributes = attributes.to_a
    end

    def matches?(target)
      @target = target
      calculate_accessible_attributes()
      perform_check()
    end

    def failure_message
      "expected #{@failed_attribute} to be accessible"
    end

    def negative_failure_message
      "expected #{@failed_attribute} to not be accessible"
    end

    private

    def calculate_accessible_attributes()
      attr_access = @target.class.send("attr_accessible").to_a.map(&:to_sym)
      @failed_attribute = []
      if((@attributes - attr_access).length != 0 or (attr_access - @attributes).length != 0)
        @failed_attribute << (@attributes - attr_access)
        @failed_attribute << (attr_access - @attributes)
      end
      nil
    end   

    def perform_check()
      @failed_attribute.empty?
    end
  end

  def accessible_attributes(*attributes)
    AccessibleAttributes.new(*attributes)
  end
end

