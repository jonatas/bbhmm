module Core
  class Share < Struct.new(:user, :to_pay, :paid)
  end
end
