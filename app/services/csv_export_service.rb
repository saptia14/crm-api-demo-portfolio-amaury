# frozen_string_literal: true

require "csv"

class CsvExportService
  def self.contacts(scope)
    CSV.generate(headers: true) do |csv|
      csv << ["id", "first_name", "last_name", "email", "phone", "company", "tags", "created_at"]

      scope.includes(:company, :tags).reorder(nil).find_each do |contact|
        csv << [
          contact.id,
          contact.first_name,
          contact.last_name,
          contact.email,
          contact.phone,
          contact.company&.name,
          contact.tag_list.to_a.join("; "),
          contact.created_at&.iso8601
        ]
      end
    end
  end

  def self.deals(scope)
    CSV.generate(headers: true) do |csv|
      csv << ["id", "name", "amount", "stage", "expected_close_date", "contact", "company", "sales_rep", "tags", "created_at"]

      scope.includes(:contact, :company, :user, :tags).reorder(nil).find_each do |deal|
        csv << [
          deal.id,
          deal.name,
          deal.amount&.to_f,
          deal.stage,
          deal.expected_close_date,
          deal.contact&.full_name,
          deal.company&.name,
          deal.user&.full_name,
          deal.tag_list.to_a.join("; "),
          deal.created_at&.iso8601
        ]
      end
    end
  end

  def self.companies(scope)
    CSV.generate(headers: true) do |csv|
      csv << ["id", "name", "industry", "website", "contacts_count", "deals_count", "created_at"]

      scope.includes(:contacts, :deals).reorder(nil).find_each do |company|
        csv << [
          company.id,
          company.name,
          company.industry,
          company.website,
          company.contacts.count,
          company.deals.count,
          company.created_at&.iso8601
        ]
      end
    end
  end
end
