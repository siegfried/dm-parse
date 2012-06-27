module DataMapper
  class Collection
    def count
      adapter = repository.adapter
      adapter.read_count query
    end
  end
end
