# Deletes given key from Rails cache
class CacheDeleteJob
  def self.perform(key)
    Rails.cache.delete(key)
  end
end
