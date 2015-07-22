module BackendsHelper
  def backend_all
    Backend.all
  end

  def name(backend)
    backend.name || backend.id.to_s
  end
end
