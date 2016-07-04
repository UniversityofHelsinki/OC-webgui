# Provides functionality for updating queue status. This is done by comparing the current status of the queue with a prior status.
# This is done by supplying the class an array of QueueItem objects, which represents the current status of the queue, and comparing
# them to QueueItem objects with an open:true status in the DB, which represent the last known state of the queue prior to the update.
#
# Queue objects do not by default have any unique identifying information, so they are identified by what information they do contain,
# as well as the time they enter the queue (current time - time_in_queue). This is not guaranteed to be 100% reliable in borderline
# cases such as when two similar contacts enter the queue (almost) simultaneously or if the time_in_status returned by OC SOAP service
# is not reliable (for example due to lag). The class will attempt to account for these cases but does not guarantee 100% accuracy.
class QueueUpdater
  # Current_time parameter should ALWAYS be current time (Time.zone.now), except for tests
  # Last_success should contain a timestamp for when the update job was previously run successfully
  def initialize(current_time, last_success)
    @current_time = current_time
    @last_success = last_success
  end

  def update_queue(new_queue)
    @previous_queue = QueueItem.where(open: true)
    @new_queue = new_queue || []
    @new_items = []

    check_when_items_entered_queue
    return false unless new_data_is_reliable
    check_if_items_left_queue
    save_updates

    true
  end

  private

  def save_updates
    items_to_close = @previous_queue.select { |item| item.id unless item.open }
    QueueItem.where(id: items_to_close)
             .update_all(open: false, closed: Time.zone.at(Time.zone.now.to_i), last_reliable_status: @last_success)
    QueueItem.create(@new_items)
  end

  # This check is used for borderline cases where the new queue status from SOAP service is not accurate due to lag. In such
  # a case an item's time_in_queue status might be inaccurate and it will not be recognized as a one of the already open
  # queue items, but as a new item instead. This will check whether it's possible for the item to be new, and if not, the
  # results of this update round should be discarded until a new reliable result can be obtained the next time the update job runs.
  def plausibly_new_item?(item)
    return true unless @last_success
    time_since_last_update = @current_time - @last_success
    item.time_in_queue < time_since_last_update
  end

  def check_when_items_entered_queue
    @new_queue.each { |item| item.created_at = Time.zone.at(@current_time.to_i - item.time_in_queue) }
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

  # Returns false if new data doesn't appear reliable, otherwise retuns true and adds new items to array for saving later
  def new_data_is_reliable
    @new_queue.each do |item|
      matches = @previous_queue.select { |match| same_item(item, match) }
      unless matches.any?
        return false unless plausibly_new_item? item
        @new_items.push(created_at: item.created_at, line: item.line, label: item.label, open: true)
      end
    end
    true
  end

  def same_item(item, match)
    match.created_at <= item.created_at + 1.second &&
      match.created_at >= item.created_at - 1.second &&
      match.line == item.line &&
      match.label == item.label
  end
end
