class ApplicationService
  def self.call(*args)
    new(*args).run
  end
end
