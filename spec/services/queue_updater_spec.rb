RSpec.describe QueueUpdater, type: :service do

  def queue_a_1
    [
      QueueItem.new(line: '131', label: 'Neuvonta Eng', time_in_queue: '10'),
      QueueItem.new(line: '161', label: 'Hakijapalvelut Fin', time_in_queue: '22')
    ]
  end

  def queue_a_2
    [
      QueueItem.new(line: '131', label: 'Neuvonta Eng', time_in_queue: '14'),
      QueueItem.new(line: '161', label: 'Hakijapalvelut Fin', time_in_queue: '26')
    ]
  end

  def queue_a_3
    [
      QueueItem.new(line: '131', label: 'Neuvonta Eng', time_in_queue: '18')
    ]
  end

  def queue_b_1
    [
      QueueItem.new(line: '131', label: 'Neuvonta Eng', time_in_queue: '12')
    ]
  end

  def queue_b_2
    [
      QueueItem.new(line: '161', label: 'Hakijapalvelut Fin', time_in_queue: '12')
    ]
  end

  def queue_c_1
    [
      QueueItem.new(line: '161', label: 'Hakijapalvelut Fin', time_in_queue: '3'),
      QueueItem.new(line: '161', label: 'Hakijapalvelut Fin', time_in_queue: '2'),
      QueueItem.new(line: '161', label: 'Hakijapalvelut Fin', time_in_queue: '3'),
    ]
  end

  def queue_c_2
    [
      QueueItem.new(line: '161', label: 'Hakijapalvelut Fin', time_in_queue: '7'),
      QueueItem.new(line: '161', label: 'Hakijapalvelut Fin', time_in_queue: '6')
    ]
  end

  def queue_c_3
    [
      QueueItem.new(line: '161', label: 'Hakijapalvelut Fin', time_in_queue: '11'),
    ]
  end



  it 'works with nil inputs' do
    QueueUpdater.new(Time.zone.now, Time.zone.now).update_queue([])
    QueueUpdater.new(Time.zone.now, Time.zone.now).update_queue(nil)
    expect(QueueItem.all.length).to eq(0)
  end

  context 'when two items enter an empty queue' do

    before (:example) do
      QueueUpdater.new(Time.zone.now, Time.zone.now - 1.minute).update_queue(queue_a_1)
    end

    it 'creates new open QueueItem objects for each new queue item and stores them in the DB' do
      expect(QueueItem.all.length).to eq(2)
      expect(QueueItem.where(open: true).length).to eq(2)
    end

    it "correctly sets their creation time according to the time they've been in the queue" do
      expect(QueueItem.first.created_at).to eq(Time.at(Time.zone.now.to_i - 10))
      expect(QueueItem.second.created_at).to eq(Time.at(Time.zone.now.to_i - 22))
    end

  end

  context 'when two items are in the queue and then disappear' do
    before(:example) do
      QueueUpdater.new(Time.zone.now, Time.zone.now - 1.minute).update_queue(queue_a_1)
      QueueUpdater.new(Time.zone.now + 15.seconds, Time.zone.now).update_queue([])
    end

    it 'creates and then closes a new QueueItem object for each of them' do
      expect(QueueItem.all.length).to eq(2)
      expect(QueueItem.where(open: false).length).to eq(2)
      expect(QueueItem.first.closed).to eq(Time.at(Time.zone.now.to_i))
      expect(QueueItem.first.created_at).to eq(Time.at(Time.zone.now.to_i - 10.seconds))
      expect(QueueItem.second.closed).to eq(Time.at(Time.zone.now.to_i))
      expect(QueueItem.second.created_at).to eq(Time.at(Time.zone.now.to_i - 22.seconds))
    end

  end

  context 'when two same items appear in the queue on subsequent searches with correctly increased time_in_status' do

    before (:example) do
      QueueUpdater.new(Time.zone.now, Time.zone.now - 1.minute).update_queue(queue_a_1)
      QueueUpdater.new(Time.zone.now + 4.seconds, Time.zone.now).update_queue(queue_a_2)
    end

    it "doesn't create new QueueItem objects" do
      expect(QueueItem.all.length).to eq(2)
    end

    it "doesn't modify the existing QueueItem objects" do
      expect(QueueItem.where(open: true).length).to eq(2)
    end

  end

  context 'when two items are in the queue, and one of them disappears' do

    before (:example) do
      QueueUpdater.new(Time.zone.now, Time.zone.now - 1.minute).update_queue(queue_a_2)
      QueueUpdater.new(Time.zone.now + 4.seconds, Time.zone.now).update_queue(queue_a_3)
    end

    it "doesn't generate any extra QueueItem objects" do
      expect(QueueItem.all.length).to eq(2)
    end

    it 'closes the item which disappeared' do
      expect(QueueItem.second.open).to be(false)
    end

    it 'sets the time the item closed correctly' do
      expect(QueueItem.second.closed).to eq(Time.at(Time.zone.now.to_i))
    end
  end

  context 'When an item in the queue disappears, and another with similar time turns up' do

    before (:example) do
      QueueUpdater.new(Time.zone.now, Time.at(Time.zone.now.to_i - 1.hour)).update_queue(queue_b_1)
      QueueUpdater.new(Time.zone.now + 20.seconds, Time.at(Time.zone.now.to_i)).update_queue(queue_b_1)
    end

    it 'closes the first item' do
      expect(QueueItem.first.open).to be(false)
    end

    it 'opens a new QueueStatus object for the new item' do
      expect(QueueItem.all.length).to be(2)
      expect(QueueItem.second.open).to be(true)
    end
  end

  context 'When it appears that the queue result is not reliable due to lag from SOAP service' do

    before (:example) do
      QueueUpdater.new(Time.zone.now, Time.at(Time.zone.now.to_i - 1.hour)).update_queue(queue_b_1)
      QueueUpdater.new(Time.zone.now + 10.seconds, Time.at(Time.zone.now.to_i)).update_queue(queue_b_1)
    end

    it "doesn't make any changes changes and awaits the next reliable result" do
      expect(QueueItem.first.open).to be(true)
      expect(QueueItem.all.length).to eq(1)
    end

  end


  context 'When three very similar items appear in the queue and one of them disappears' do

    before (:example) do
      time = Time.at(Time.zone.now.to_i)
      QueueUpdater.new(time, time - 1.hour).update_queue(queue_c_1)
      QueueUpdater.new(time + 4.seconds, time).update_queue(queue_c_2)
    end

    it "doesn't generate any new QueueItem objects" do
      expect(QueueItem.all.length).to eq(3)
    end

    it 'closes only one item' do
      expect(QueueItem.where(open: true).length).to eq(2)
    end

    it 'sets the last reliable status time for the closed item correctly' do
      expect(QueueItem.where(open: false)[0].last_reliable_status).to eq(Time.at(Time.zone.now.to_i))
    end

    context 'and then another item disappears from the queue' do

      before (:example) do
        QueueUpdater.new(Time.zone.now + 8.seconds, Time.at(Time.zone.now.to_i + 4.seconds)).update_queue(queue_c_3)
      end

      it 'closes another one when yet another item disappears' do
        expect(QueueItem.all.length).to eq(3)
        expect(QueueItem.where(open: true).length).to eq(1)
      end

      it 'sets the last reliable status time for the newly closed item correctly' do
        expect(QueueItem.where(open:false)[1].last_reliable_status).to eq(Time.at(Time.zone.now.to_i + 4.seconds))
      end
    end
  end

  context 'When an item disappears from the queue and no last relialbe result is recorded' do

    before(:example) do
      QueueUpdater.new(Time.zone.now, nil).update_queue(queue_b_1)
    end

    it 'creates a new open QueueItem as normal' do
      expect(QueueItem.all.length).to eq(1)
      expect(QueueItem.first.open).to be(true)
    end

    it "doesn't record a last reliable status for the item" do
      expect(QueueItem.first.last_reliable_status).to be(nil)
    end

  end

end
