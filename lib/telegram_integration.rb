require 'telegram/bot'
require './lib/core'

token = ENV['TELEGRAM_TOKEN']

def split
  @split ||= Core.split(Core.expense(description: 'House Rental', amount: 4500), %w[])
end

Telegram::Bot::Client.run(token) do |bot|

  bot.listen do |message|
    user = message.from.first_name
    case message.text
    when "/start"
      puts "started", message
      bot.api.send_message(chat_id: message.chat.id, text: split.inspect)
    when "/addme"
      split.split_also_with user
      bot.api.send_message(chat_id: message.chat.id, text: split.inspect)
    when /\/pago\s+\d+/
      value = message.text[/(\d+)/].to_i
      split.split_also_with user
      split.add_payment user, value
      bot.api.send_message(chat_id: message.chat.id, text: split.inspect)
    when "/status"
      msg = <<~MSG
        Paid: #{split.paid}
        Missing Value: #{split.missing_value}
        Suggested Amount: #{split.suggested_amount}
      MSG
      bot.api.send_message(chat_id: message.chat.id, text: msg)
    when /despesa|pag(o|uei)|compr(ei|ado).*\d+/
      amount_text = message.text.scan(/\d+(\.\d+)?/).first
      expense = Core.expense description: message.text, amount: amount_text.to_f
      bot.api.send_message(chat_id: message.chat.id, text: "Computed #{expense}, #{message.from.first_name}!")
    else
      bot.api.send_message(chat_id: message.chat.id, text: "Pong: #{message.text.inspect}")
    end
  end
end
