RSpec.describe QueueUpdater, type: :service do
  time = Time.parse('2016-07-18T11:37:55.000Z')

  def updater(*args)
    QueueUpdater.new(*args)
  end

  def build(*args)
    FactoryGirl.build(*args)
  end

  it 'works with nil inputs' do
    updater(time, time).update_queue([])
    updater(time, time).update_queue(nil)
    expect(QueueItem.all.length).to eq(0)
  end

  context 'when two items enter an empty queue' do
    before (:example) do
      data = [build(:item_1), build(:item_2)]
      updater(time, time - 1.minute).update_queue(data)
    end

    it 'creates new open QueueItem objects for each new queue item and stores them in the DB' do
      expect(QueueItem.all.length).to eq(2)
      expect(QueueItem.where(open: true).length).to eq(2)
    end

    it "correctly sets their creation time according to the time they've been in the queue" do
      expect(QueueItem.first.created_at).to eq('2016-07-18T11:37:45.000Z')
      expect(QueueItem.second.created_at).to eq('2016-07-18T11:37:33.000Z')
    end
  end

  context 'when two items are in the queue and then disappear' do
    before(:example) do
      data = [build(:item_1), build(:item_2)]
      updater(time, time - 1.minute).update_queue(data)
      updater(time + 15.seconds, time).update_queue([])
    end

    it 'creates and then closes a new QueueItem object for each of them' do
      expect(QueueItem.all.length).to eq(2)
      expect(QueueItem.where(open: false).length).to eq(2)
      expect(QueueItem.first.closed).to eq(time + 15.seconds)
      expect(QueueItem.first.created_at).to eq(time - 10.seconds)
      expect(QueueItem.second.closed).to eq(time + 15.seconds)
      expect(QueueItem.second.created_at).to eq(time - 22.seconds)
    end

  end

  context 'when two same items appear in the queue on subsequent searches with correctly increased time_in_status' do

    before (:example) do
      data1 = [build(:item_1), build(:item_2)]
      data2 = [build(:item_1, time_in_queue: "14"), build(:item_2, time_in_queue: "26")]
      updater(time, time - 1.minute).update_queue(data1)
      updater(time + 4.seconds, time).update_queue(data2)
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
      data1 = [build(:item_1), build(:item_2)]
      data2 = [build(:item_1, time_in_queue: "14")]
      updater(time, time - 1.minute).update_queue(data1)
      updater(time + 4.seconds, time).update_queue(data2)
    end

    it "doesn't generate any extra QueueItem objects" do
      expect(QueueItem.all.length).to eq(2)
    end

    it 'closes the item which disappeared' do
      expect(QueueItem.second.open).to be(false)
    end

    it 'sets the time the item closed correctly' do
      expect(QueueItem.second.closed).to eq(time + 4.seconds)
    end
  end

  context 'When an item in the queue disappears, and another with similar time turns up' do
    before (:example) do
      data = [build(:item_1)]
      updater(time, time - 1.hour).update_queue(data)
      updater(time + 20.seconds, time).update_queue(data)
    end

    it 'closes the first item' do
      expect(QueueItem.first.open).to be(false)
    end

    it 'opens a new QueueStatus object for the new item' do
      expect(QueueItem.all.length).to eq(2)
      expect(QueueItem.second.open).to be(true)
    end
  end

  context 'When it appears that the queue result is not reliable due to lag from SOAP service' do
    before (:example) do
      data = [build(:item_2, time_in_queue: "25")]
      updater(time, time - 1.hour).update_queue(data)
      updater(time + 10.seconds, time).update_queue(data)
    end

    it "doesn't make any changes and awaits the next reliable result" do
      expect(QueueItem.first.open).to be(true)
      expect(QueueItem.all.length).to eq(1)
    end
  end


  context 'When three very similar items appear in the queue and one of them disappears' do
    before (:example) do
      data1 = [build(:item_1, time_in_queue: "3"), build(:item_1, time_in_queue: "2"), build(:item_1, time_in_queue: "3")]
      data2 = [build(:item_1, time_in_queue: "7"), build(:item_1, time_in_queue: "6")]
      updater(time, time - 1.hour).update_queue(data1)
      updater(time + 4.seconds, time).update_queue(data2)
    end

    it "doesn't generate any new QueueItem objects" do
      expect(QueueItem.all.length).to eq(3)
    end

    it 'closes only one item' do
      expect(QueueItem.where(open: true).length).to eq(2)
    end

    it 'sets the last reliable status time for the closed item correctly' do
      expect(QueueItem.where(open: false)[0].last_reliable_status).to eq(time)
    end

    context 'and then another item disappears from the queue' do
      before (:example) do
        data = [build(:item_1, time_in_queue: "11")]
        updater(time + 8.seconds, time + 4.seconds).update_queue(data)
      end

      it 'closes another one when yet another item disappears' do
        expect(QueueItem.all.length).to eq(3)
        expect(QueueItem.where(open: true).length).to eq(1)
      end

      it 'sets the last reliable status time for the newly closed item correctly' do
        expect(QueueItem.where(open:false)[1].last_reliable_status).to eq(time + 4.seconds)
      end
    end
  end

  context 'When an item disappears from the queue and no last reliable result is recorded' do

    before(:example) do
      data = [build(:item_1)]
      updater(time, nil).update_queue(data)
      updater(time + 4.seconds, nil).update_queue(nil)
    end

    it 'creates a new open QueueItem as normal' do
      expect(QueueItem.all.length).to eq(1)
      expect(QueueItem.first.open).to be(false)
    end

    it "doesn't record a last reliable status for the item" do
      expect(QueueItem.first.last_reliable_status).to be(nil)
    end

  end

end
