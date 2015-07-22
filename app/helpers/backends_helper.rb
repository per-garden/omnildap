module BackendsHelper
  def backend_all
    Backend.all
  end

  def name(backend)
    backend.name.blank? ? backend.id.to_s : backend.name
  end
end
