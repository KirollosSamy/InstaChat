class Application < ApplicationRecord    
    DISALLOWED_COLUMNS = %w[id].freeze
end
