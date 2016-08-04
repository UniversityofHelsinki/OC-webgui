# DEPRECATED: Class is currently not used as more accurate data is provided by ContactsService
# Provides functionality for updating queue status. This is done by comparing the current status of the queue with a prior status.
# This is done by supplying the class an array of QueueItem objects, which represents the current status of the queue, and comparing
# them to QueueItem objects with an open:true status in the DB, which represent the last known state of the queue prior to the update.
#
# Queue objects do not by default have any unique identifying information, so they are identified by what information they do contain,
# as well as the time they enter the queue (current time - time_in_queue). This is not guaranteed to be 100% reliable in borderline
# cases such as when two similar contacts enter the queue (almost) simultaneously or if the time_in_status returned by OC SOAP service
# is not reliable (for example due to lag).
class QueueUpdater
  include Now
  # Current_time parameter should ALWAYS be current time (Time.zone.now), except for tests
  # Last_success should contain a timestamp for when the update job was previously run successfully
  def initialize(current_time, last_success)
    @current_time = current_time || now
    @last_success = last_success
  end

  def update_queue(new_queue)
    @previous_queue = QueueItem.where(open: true)
    @new_queue = new_queue || []
    @new_items = []

    check_when_items_entered_queue
    check_for_new_items
    check_if_items_left_queue
    save_updates
  end

  private

  def save_updates
    items_to_close = @previous_queue.select { |item| item.id unless item.open }
    QueueItem.where(id: items_to_close)
             .update_all(open: false, closed: @current_time, last_reliable_status: @last_success)
    QueueItem.create(@new_items)
  end

  def check_when_items_entered_queue
    @new_queue.each { |item| item.created_at = Time.zone.at(@current_time.to_i - item.time_in_queue.to_i) }
  end

  def check_if_items_left_queue
    @previous_queue.each do |item|
      # These checks exist to account for borderline cases where more than 1 items that have the same
      # attributes enter the queue simulatenously, and one or more of them later exit the queue.
      similar_old_ones = @previous_queue.select { |match| same_item(item, match) && match.open }
      similar_new_ones = @new_queue.select { |match| same_item(item, match) }

      item.open = false if similar_new_ones.length < similar_old_ones.length
    end
  end

  # Will check for any new items that it can't match to existing old ones. NOTE: It is possible for
  # the same_item check to fail due to lag in SOAP reply, even if the items are actually the same.
  # This means that the same item may be duplicated (the old one will be closed and a new one opened).
  # This is considered acceptable because accurate Queue stats can be calculated from Contact data.
  def check_for_new_items
    @new_queue.each do |item|
      matches = @previous_queue.select { |match| same_item(item, match) }
      unless matches.any?
        @new_items.push(created_at: item.created_at, service_id: item.service_id, open: true)
      end
    end
  end

  def same_item(item, match)
    match.created_at <= item.created_at + 2.seconds &&
      match.created_at >= item.created_at - 2.seconds &&
      match.service_id == item.service_id
  end
end
