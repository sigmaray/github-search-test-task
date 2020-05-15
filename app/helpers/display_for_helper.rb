module DisplayForHelper
  class DisplayBlock
    def initialize(object, helper)
      @object = object
      @helper = helper
    end

    def display(field, label = nil, &block)
      return unless @object.public_send(field).present?

      content = if block_given?
                  @helper.capture(@object.public_send(field), &block)
                else
                  @object.public_send(field)
                end

      disp_label = label || field.to_s.split('_').collect(&:capitalize).join(' ')

      @helper.content_tag :tr do
        @helper.concat @helper.content_tag :td, disp_label, class: 'pl-3 pr-3', width: '1'
        @helper.concat @helper.content_tag :td, content, class: 'pl-3 pr-3'
      end
    end
  end

  def display_for(object, options = {}, &block)
    raise ArgumentError, 'Missing block' unless block_given?
    raise ArgumentError, 'First argument cannot be blank' unless object.present?

    table_class = ['table table-bordered', options[:class]].compact.join(' ')

    content_tag :table, class: table_class do
      capture(DisplayBlock.new(object, self), &block)
    end
  end
end
