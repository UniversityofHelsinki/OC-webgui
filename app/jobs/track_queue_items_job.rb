class TrackQueueItemsJob
	def perform
		current = BackendService.new.get_general_queue.map do |data|
			AgentStatus.new(line: data[:line],
        label: data[:label],
        time_in_queue: data[:time_in_queue])
		end

		previous = Rails.cache.read("get_general_queue")
		QueueUpdater.new.update_queue(previous, current)
		Rails.cache.write("get_general_queue", current)		
	end
end
