RSpec.describe QueueUpdater, type: :service do

	def queue_a_1
		[
			QueueItem.new(line: "131", label: "Neuvonta Eng", time_in_queue: "10"),
			QueueItem.new(line: "161", label: "Hakijapalvelut Fin", time_in_queue: "22")
		]
	end

	def queue_a_2
		[
			QueueItem.new(line: "131", label: "Neuvonta Eng", time_in_queue: "14"),
			QueueItem.new(line: "161", label: "Hakijapalvelut Fin", time_in_queue: "26")
		]	
	end

	def queue_a_3
		[
			QueueItem.new(line: "131", label: "Neuvonta Eng", time_in_queue: "18")
		]
	end

	def queue_b_1
		[
			QueueItem.new(line: "131", label: "Neuvonta Eng", time_in_queue: "12")
		]
	end

	def queue_b_2
		[
			QueueItem.new(line: "161", label: "Hakijapalvelut Fin", time_in_queue: "12")
		]
	end

	def queue_c_1
		[
			QueueItem.new(line: "131", label: "Nevuonta Eng", time_in_queue: "3")
		]
	end

	def queue_d_1
		[
			QueueItem.new(line: "161", label: "Hakijapalvelut Fin", time_in_queue: "5"),
			QueueItem.new(line: "161", label: "Hakijapalvelut Fin", time_in_queue: "5")
		]
	end

	def queue_d_2
		[
			QueueItem.new(line: "161", label: "Hakijapalvelut Fin", time_in_queue: "5"),
			QueueItem.new(line: "161", label: "Hakijapalvelut Fin", time_in_queue: "12")
		]
	end

	it "works with nil inputs" do 
		QueueUpdater.new(Time.zone.now).update_queue([])
		QueueUpdater.new(Time.zone.now).update_queue(nil)
    end

	context "when two items enter an empty queue" do

		before (:example) do 
			QueueUpdater.new(Time.zone.now).update_queue(queue_a_1)
		end

		it "creates new open QueueItem objects for each new queue item and stores them in the DB" do
			expect(QueueItem.all.length).to eq(2)
			expect(QueueItem.where(open: true).length).to eq(2)
		end

		it "correctly sets their creation time according to the time they've been in the queue" do
			expect(QueueItem.first.created_at).to eq(Time.at(Time.zone.now.to_i - 10))
			expect(QueueItem.second.created_at).to eq(Time.at(Time.zone.now.to_i - 22))
		end

	end

	context "when the two same items appear in the queue on subsequent searches" do

		before (:example) do			
			QueueUpdater.new(Time.zone.now).update_queue(queue_a_1)
			QueueUpdater.new(Time.zone.now + 4.seconds).update_queue(queue_a_2)
		end

		it "doesn't create new QueueItem objects" do 
			expect(QueueItem.all.length).to eq(2)			
		end

		it "doesn't modify the existing QueueItem objects" do
			expect(QueueItem.where(open: true).length).to eq(2)
		end

	end

	context "when two items are in the queue, and one of them disappears" do

		before (:example) do 
			QueueUpdater.new(Time.zone.now).update_queue(queue_a_2)
			QueueUpdater.new(Time.zone.now + 4.seconds).update_queue(queue_a_3)
		end

		it "doesn't generate any extra QueueItem objects" do
			expect(QueueItem.all.length).to eq(2)
		end

		it "closes the item which disappeared" do
			expect(QueueItem.second.open).to be(false)
		end

		it "sets the time the item closed correctly" do
			expect(QueueItem.second.closed).to eq(Time.at(Time.zone.now.to_i))
		end
	end

	context "When an item in the queue disappears, and another with similar time turns up" do

		before (:example) do 
			QueueUpdater.new(Time.zone.now).update_queue(queue_b_1)
			QueueUpdater.new(Time.zone.now + 12.seconds).update_queue(queue_b_1)
		end

		it "closes the first item" do
			expect(QueueItem.first.open).to be(false)
		end

		it "opens a new QueueStatus object for the new item" do 
			expect(QueueItem.all.length).to be(2)
			expect(QueueItem.second.open).to be(true)
		end
	end

	context "When the same result is returned several times over a short period of time" do

		before (:example) do
			QueueUpdater.new(Time.zone.now).update_queue(queue_c_1)
			QueueUpdater.new(Time.zone.now + 1.second).update_queue(queue_c_1)
			QueueUpdater.new(Time.zone.now + 2.seconds).update_queue(queue_c_1)
		end

		it "doesn't create a new QueueItem for the object" do
			
		end

	end





  



end