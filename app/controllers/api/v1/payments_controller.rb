# frozen_string_literal: true

module Api
  module V1
    class PaymentsController < ApplicationController
      # Only admins are authorized to trigger payment processing for a tenant.
      def process_payment
        # Authorization check (Policy defined below)
        authorize :payment, :process?

        card_details = params.require(:payment).permit(:name, :number, :expiry, :cvc)
        amount = 99.00 # Fixed price for the demo Pro Plan

        result = MockPaymentService.process(card_details, amount)

        if result[:success]
          # Create financial records upon successful payment
          Invoice.create!(
            amount: amount,
            status: :paid,
            due_date: Date.current
          )

          Subscription.create!(
            plan_name: "Pro Plan",
            price: amount,
            status: :active
          )

          render json: {
            success: true,
            transaction_id: result[:transaction_id],
            message: "Subscription activated!"
          }, status: :ok
        else
          render json: {
            success: false,
            error: result[:error]
          }, status: :payment_required
        end
      end
    end
  end
end
