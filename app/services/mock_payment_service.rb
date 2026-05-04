# frozen_string_literal: true

class MockPaymentService
  # Simulates a payment gateway transaction.
  # Includes artificial latency and a randomized success rate.
  def self.process(_card_details, _amount)
    # Simulate network latency (1-2 seconds)
    sleep(rand(1.0..2.0))

    # Simulate 80% success rate
    if rand(1..100) <= 80
      {
        success: true,
        transaction_id: "txn_#{SecureRandom.hex(8)}",
        message: "Payment processed successfully"
      }
    else
      {
        success: false,
        error: "Insufficient funds or card declined",
        message: "Payment failed"
      }
    end
  end
end
