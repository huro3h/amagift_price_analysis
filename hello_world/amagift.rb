require 'json'
require 'mechanize'
require 'active_record'
require 'slack-notifier'

class Amagift
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serializers::JSON

  PERCENTAGE = 100
  BASE_URL = ENV['BASE_URL']

  attr_accessor :agent, :page, :result
  attr_accessor :quantity, :ticket_value, :price
  attr_accessor :discount_rate
  attr_accessor :expired_date
  attr_accessor :performance, :performance_rate

  def scrape!
    @agent = Mechanize.new
    @page = agent.get(BASE_URL)
    @result = page.search('table.sale_list').search('tr').first(2)
  end

  def set_attributes!
    @quantity, @ticket_value, @price = self.result[1].search('span.fl').map(&:text).map { |str| str.tr(',', '') }.map(&:to_i)
    @discount_rate = calculate_discount_rate
    @expired_date = self.result[1].search('td.pc').text

    actual_trade = self.result[1].search('td').map(&:text)[6].tr("()", " ").strip
    @performance, @performance_rate = actual_trade.split
  end

  def formatted_text
    # text = "数量: #{self.quantity}\n"
    text = "額面: #{self.ticket_value}\n"
    text << "販売価格: #{self.price}\n"
    text << "割引率: #{self.discount_rate}\n\n"
    # text << "取引実績: #{self.performance}(#{@performance_rate})"
    text
  end

  private

  def calculate_discount_rate
    return 0 unless @price && @ticket_value

    rate = (@price.to_f / @ticket_value.to_f) * PERCENTAGE
    rate.round(1)
  end

  # return <Array> [Integer]
  # [1, 200000, 151800]
  # 販売枚数, 額面, 販売価格

  # # return <Array>
  # # ["2030/09/13"]
  # # 有効期限
  # expired_date = result[1].search('td.pc').text

  # # return <String>
  # # "2,277,965 98.7%"
  # actual_trade = result[1].search('td').map(&:text)[6].tr("()", " ").strip

  # # return <Array>
  # # ["2,277,965", "98.7%"]
  # performance, performance_rate = actual_trade.split
end

