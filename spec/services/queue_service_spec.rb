RSpec.describe QueueService, type: :service do
  time = Time.zone.parse('2016-07-18T08:00:00 +0300')

  def build(*args)
    FactoryGirl.build(*args)
  end

  before(:example) do    
    build(:team_1).save
    build(:service_1).save
    build(:qitem, created_at: time, closed: time + 10.seconds).save
    build(:qitem, created_at: time + 1.hour, closed: time + (1.hour + 10.seconds)).save
    build(:qitem, created_at: time + 2.hours, closed: time + (2.hours + 2.minutes)).save
    build(:qitem, created_at: time + 4.hours, closed: time + (4.hours + 20.seconds)).save
    build(:qitem, created_at: time + (4.hours + 15.minutes), closed: time + (4.hours + 20.minutes)).save
    build(:qitem, created_at: time + (5.hours + 59.minutes), closed: time + (6.hours + 30.seconds)).save
    build(:qitem, created_at: time + 7.hours, open: true).save
  end

  it "Correctly calculates average queue time" do
    expect(QueueService.new.average_queueing_duration('Helpdesk', '2016-07-17', '2016-07-19')).to eq(92)
  end

  it "Calculates number of people who entered queue by hour correctly" do
    expect(QueueService.new.queue_items_by_hour('Helpdesk', '2016-07-17', '2016-07-19')).to eq([0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
  end  
end
