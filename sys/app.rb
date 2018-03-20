class App
  def call(env)
    [status, headers, body]
  end

  private

  def status
    Rack::Utils::SYMBOL_TO_STATUS_CODE[:ok]
  end

  def headers
    { 'Contant-type' => 'text/plain' }
  end

  def body
    []
  end
end
