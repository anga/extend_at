require File.expand_path('../table_manager', __FILE__)

module ExtendModelAt

  # Manage the environment of structure function
  class Structure
    def run
      yield TableManager.new
      TableManager.send :config         # Get te configuration (is protected)
    end
  end
end
