# Provides functionality for updating queue status. This is done by comparing the current status of the queue with a prior status.
# This is done by supplying the class an array of QueueItem objects, which represents the current status of the queue, and comparing
# them to QueueItem objects with an open:true status in the DB, which represent the last known state of the queue prior to the update.
#
# Queue objects do not by default have any unique identifying information, so they are identified by what information they do contain,
# as well as the time they enter the queue (current time - time_in_queue). This is not guaranteed to be 100% reliable in borderline
# cases such as when two similar contacts enter the queue (almost) simultaneously or if the time_in_status returned by OC SOAP service
# is not reliable (for example due to lag). This may cause miscalculations in the times items appear to be in the queue.
class QueueUpdater
  # Current_time parameter should ALWAYS be current time (Time.zone.now), except for tests
  # Last_success should contain a timestamp for when the update job was previously run successfully
  def initialize(current_time, last_success)
    @timestamp = current_time
    @last_success = last_success
  end

  def update_queue(new_queue)
    @previous_queue = QueueItem.where(open: true)
    @new_queue = new_queue || []

    assign_created_at
    update_items_left_queue
    update_new_queue_items

  end

  private

    def assign_created_at
      @new_queue.each { |item| item.created_at = Time.at(@timestamp.to_i - item.time_in_queue) }
    end

    def update_items_left_queue
      @previous_queue.each do |item|
        # These checks exist to account for borderline cases where more than 1 items that have the same
        # attributes enter the queue simulatenously, and one or more of them later exit the queue.
        similar_old_ones = @previous_queue.select { |match| match.created_at <= item.created_at + 1.second &&
                                                            match.created_at >= item.created_at - 1.second &&
                                                            match.line == item.line &&
                                                            match.label == item.label &&
                                                            match.open }

        similar_new_ones = @new_queue.select { |match| match.created_at <= item.created_at + 1.second &&
                                              match.created_at >= item.created_at - 1.second &&
                                              match.line == item.line &&
                                              match.label == item.label }

        if similar_new_ones.length < similar_old_ones.length
          item.open = false
          item.closed = Time.zone.at(Time.zone.now.to_i)
          if @last_success
            item.last_reliable_status = @last_success
          else
            item.last_reliable_status = item.created_at
          end
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
