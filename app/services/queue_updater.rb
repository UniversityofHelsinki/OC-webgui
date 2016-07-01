class QueueUpdater
  # Current_time parameter should ALWAYS be current time (Time.zone.now), except for tests
  def initialize(current_time)
    @timestamp = current_time
  end

  def update_queue(new_queue)
    previous_queue = QueueItem.where(open: true)
    previous_queue = [] unless previous_queue
    new_queue = [] unless new_queue

    @previous_queue = previous_queue
    @new_queue = new_queue

    assign_created_at(new_queue)
    update_items_left_queue
    update_new_queue_items

  end

  private

    def assign_created_at(items)
      items.each { |item| item.created_at = Time.at(@timestamp.to_i - item.time_in_queue) }
    end

    def update_items_left_queue
      @previous_queue.each do |item|
        matches = @new_queue.select { |match| match.created_at <= item.created_at + 1.second &&
                                              match.created_at >= item.created_at - 1.second && 
                                              match.line == item.line &&
                                              match.label == item.label }
        unless matches.any?
          item.open = false
          item.closed = Time.at(Time.zone.now.to_i)
          item.save
        end
      end
      
    end

    def update_new_queue_items

      @new_queue.each do |item|
        matches = @previous_queue.select { |match| match.created_at <= item.created_at + 1.second &&
                                                   match.created_at >= item.created_at - 1.second && 
                                                   match.line == item.line &&
                                                   match.label == item.label }
        
        QueueItem.create(created_at: item.created_at, line: item.line, label: item.label, open: true) unless matches.any?
      end

    end

end
