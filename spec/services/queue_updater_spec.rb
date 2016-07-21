RSpec.describe QueueUpdater, type: :service do
  include Now

  def updater(*args)
    QueueUpdater.new(*args)
  end

  def build(*args)
    FactoryGirl.build(*args)
  end

  before (:all) do 
    Service.find_or_create_by(id: 161, name: "A")
    Service.find_or_create_by(id: 131, name: "B")
  end

  it 'works with nil inputs' do
    updater(now, now).update_queue([])
    updater(now, now).update_queue(nil)
    expect(QueueItem.all.length).to eq(0)
  end

  context 'when two items enter an empty queue' do
    before (:example) do
      data = [build(:item_1), build(:item_2)]
      updater(now, now - 1.minute).update_queue(data)
    end

    it 'creates new open QueueItem objects for each new queue item and stores them in the DB' do
      expect(QueueItem.all.length).to eq(2)
      expect(QueueItem.where(open: true).length).to eq(2)
    end

    it "correctly sets their creation time according to the time they've been in the queue" do
      expect(QueueItem.first.created_at).to eq(now - 10.seconds)
      expect(QueueItem.second.created_at).to eq(now - 22.seconds)
    end
  end

  context 'when two items are in the queue and then disappear' do
    before(:example) do
      data = [build(:item_1), build(:item_2)]
      updater(now, now - 1.minute).update_queue(data)
      updater(now + 15.seconds, now).update_queue([])
    end

    it 'creates and then closes a new QueueItem object for each of them' do
      expect(QueueItem.all.length).to eq(2)
      expect(QueueItem.where(open: false).length).to eq(2)
      expect(QueueItem.first.closed).to eq(now + 15.seconds)
      expect(QueueItem.first.created_at).to eq(now - 10.seconds)
      expect(QueueItem.second.closed).to eq(now + 15.seconds)
      expect(QueueItem.second.created_at).to eq(now - 22.seconds)
    end

  end

  context 'when two same items appear in the queue on subsequent searches with correctly increased time_in_status' do

    before (:example) do
      data1 = [build(:item_1), build(:item_2)]
      data2 = [build(:item_1, time_in_queue: "14"), build(:item_2, time_in_queue: "26")]
      updater(now, now - 1.minute).update_queue(data1)
      updater(now + 4.seconds, now).update_queue(data2)
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
      updater(now, now - 1.minute).update_queue(data1)
      updater(now + 4.seconds, now).update_queue(data2)
    end

    it "doesn't generate any extra QueueItem objects" do
      expect(QueueItem.all.length).to eq(2)
    end

    it 'closes the item which disappeared' do
      expect(QueueItem.second.open).to be(false)
    end

    it 'sets the time the item closed correctly' do
      expect(QueueItem.second.closed).to eq(now + 4.seconds)
    end
  end

  context 'When an item in the queue disappears, and another with similar time turns up' do
    before (:example) do
      data = [build(:item_1)]
      updater(now, now - 1.hour).update_queue(data)
      updater(now + 20.seconds, now).update_queue(data)
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
      updater(now, now - 1.hour).update_queue(data)
      updater(now + 10.seconds, now).update_queue(data)
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
      updater(now, now - 1.hour).update_queue(data1)
      updater(now + 4.seconds, now).update_queue(data2)
    end

    it "doesn't generate any new QueueItem objects" do
      expect(QueueItem.all.length).to eq(3)
    end

    it 'closes only one item' do
      expect(QueueItem.where(open: true).length).to eq(2)
    end

    it 'sets the last reliable status time for the closed item correctly' do
      expect(QueueItem.where(open: false)[0].last_reliable_status).to eq(now)
    end

    context 'and then another item disappears from the queue' do
      before (:example) do
        data = [build(:item_1, time_in_queue: "11")]
        updater(now + 8.seconds, now + 4.seconds).update_queue(data)
      end

      it 'closes another one when yet another item disappears' do
        expect(QueueItem.all.length).to eq(3)
        expect(QueueItem.where(open: true).length).to eq(1)
      end

      it 'sets the last reliable status time for the newly closed item correctly' do
        expect(QueueItem.where(open:false)[1].last_reliable_status).to eq(now + 4.seconds)
      end
    end
  end

  context 'When an item disappears from the queue and no last reliable result is recorded' do

    before(:example) do
      data = [build(:item_1)]
      updater(now, nil).update_queue(data)
      updater(now + 4.seconds, nil).update_queue(nil)
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
