module Router
  def self.included(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end

  module ClassMethods
    DEFAULT_ACTIONS = { get: :index }.freeze
    def resource(name)
      variable_name = :@@routes
      class_variable_set(variable_name, {}) unless class_variable_defined?(variable_name)
      routes = class_variable_get(variable_name)
      DEFAULT_ACTIONS.each do |verb, action|
        # Only one action
        routes["/#{name}"] = { controller: controller_name(name),
                               action: action,
                               verb: verb }
      end
      class_variable_set(variable_name, routes)
    end

    private

    def controller_name(name)
      "#{name.capitalize}Controller"
    end
  end

  module InstanceMethods
    # Rack requirement
    def initialize(app)
      @app = app
    end

    # Rack requirement
    def call(env)
      @request = Rack::Request.new(env)
      status, headers, body = @app.call(env)

      if path_not_found?
        status = status_code(:not_found)
      elsif controller_invalid? || bad_request_method?
        status_code(:bad_request)
      else
        begin
          body = [execute_controller]
        rescue StandardError => error
          body = [error.message]
          status = status_code(:bad_request)
        end
      end

      [status, headers, body]
    end

    private

    def request_methods
      %w[get post put patch delete]
    end

    def routes
      self.class.class_variable_get(:@@routes)
    end

    def status_code(stat)
      Rack::Utils::SYMBOL_TO_STATUS_CODE[stat]
    end

    def execute_controller
      new_controller = Object.const_get(controller).new(query_string)
      new_controller.send action
    end

    def controller
      routes[request_path][:controller]
    end

    def action
      routes[request_path][:action]
    end

    def verb
      routes[request_path][:verb]
    end

    def controller_invalid?
      !controller? || !action? || verb.to_s != request_method.to_s
    end

    def bad_request_method?
      !request_method?
    end

    def controller?
      Object.const_defined?(controller)
    end

    def action?
      Object.const_get(controller).instance_methods.include?(action.to_sym)
    end

    def path_not_found?
      !path?
    end

    def path?
      routes.include?(request_path)
    end

    def request_method?
      request_methods.include?(request_method)
    end

    def request_method
      @request.request_method.downcase
    end

    def query_string
      Rack::Utils.default_query_parser.parse_query(@request.query_string)
    end

    def request_path
      @request.path
    end
  end
end
