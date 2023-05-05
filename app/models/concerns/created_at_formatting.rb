# frozen_string_literal: true

module CreatedAtFormatting
  extend ActiveSupport::Concern

  included do
    def formatted_created_at
      created_at.strftime('%Y-%m-%d %H:%M:%S')
    end
  end
end
