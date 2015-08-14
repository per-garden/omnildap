class BackendSync

  def sync
    Backend.all.each do |b|
      b.find_users
    end
  end
end
