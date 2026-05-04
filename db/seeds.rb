# frozen_string_literal: true

# This file contains the seed data for the CRM API development environment.
# Run with: rails db:seed
#
# Phase 3: Generates rich, segmented dummy data using Faker.
# CAUTION: This script clears ALL existing data before seeding.

require "faker"

puts "🌱 Seeding CRM API database (Phase 3)..."
puts "=" * 60

# === Clear existing data ===
puts "\n🗑️  Clearing existing data..."
ActsAsTenant.without_tenant do
  Invoice.destroy_all
  Subscription.destroy_all
  Note.destroy_all
  Deal.destroy_all
  Contact.destroy_all
  Company.destroy_all
  User.destroy_all
  Tenant.destroy_all

  # Clear tagging data
  ActsAsTaggableOn::Tagging.destroy_all
  ActsAsTaggableOn::Tag.destroy_all
end
puts "   ✅ All data cleared."

# === Create Tenants ===
puts "\n🏢 Creating tenants..."
tenants_data = [
  { name: "Acme Corp", subdomain: "acme", active: true },
  { name: "Globex Corporation", subdomain: "globex", active: true },
  { name: "Initech", subdomain: "initech", active: true }
]

tenants = tenants_data.map do |attrs|
  tenant = Tenant.create!(attrs)
  puts "   ✅ #{tenant.name} (#{tenant.subdomain})"
  tenant
end

# === Seed each tenant ===
tenants.each do |tenant|
  puts "\n" + "─" * 60
  puts "📦 Seeding tenant: #{tenant.name}"
  puts "─" * 60

  ActsAsTenant.with_tenant(tenant) do
    # --- Users (1 Admin, 1 Manager, 2 Sales Reps) ---
    puts "\n  👤 Creating users..."

    admin = User.create!(
      email: "admin@#{tenant.subdomain}.example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      role: :admin,
      tenant: tenant
    )
    puts "     ✅ Admin: #{admin.email}"

    super_admin = User.create!(
      email: "superadmin@#{tenant.subdomain}.example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Super",
      last_name: "Admin",
      role: :super_admin,
      tenant: tenant
    )
    puts "     ✅ Super Admin: #{super_admin.email}"

    manager = User.create!(
      email: "manager@#{tenant.subdomain}.example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      role: :manager,
      tenant: tenant
    )
    puts "     ✅ Manager: #{manager.email}"

    sales_reps = 2.times.map do |i|
      rep = User.create!(
        email: "sales#{i + 1}@#{tenant.subdomain}.example.com",
        password: "password123",
        password_confirmation: "password123",
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        role: :sales_rep,
        tenant: tenant
      )
      puts "     ✅ Sales Rep: #{rep.email}"
      rep
    end

    all_users = [super_admin, admin, manager] + sales_reps

    # --- Companies (5 per tenant) ---
    puts "\n  🏗️  Creating companies..."

    industries = ["Technology", "Healthcare", "Finance", "Manufacturing", "Retail"]
    companies = 5.times.map do |i|
      company = Company.create!(
        name: Faker::Company.name,
        industry: industries[i],
        website: "https://#{Faker::Internet.domain_name}",
        tenant: tenant
      )
      puts "     ✅ #{company.name} (#{company.industry})"
      company
    end

    # --- Contacts (10 per tenant, distributed among companies) ---
    puts "\n  📇 Creating contacts..."

    contact_tags = ["vip", "decision-maker", "technical", "executive", "influencer"]
    contacts = 10.times.map do |i|
      company = companies[i % companies.length]
      contact = Contact.create!(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.email,
        phone: Faker::PhoneNumber.phone_number,
        company: company,
        tenant: tenant
      )
      # Assign 1-2 random tags to each contact
      num_tags = rand(1..2)
      contact.tag_list.add(contact_tags.sample(num_tags))
      contact.save!
      puts "     ✅ #{contact.full_name} → #{company.name} [#{contact.tag_list.join(', ')}]"
      contact
    end

    # --- Deals (current month + previous month for dashboard charts) ---
    puts "\n  💰 Creating deals..."

    stages = [:prospect, :qualification, :proposal, :won, :lost]
    deal_tags = ["urgent", "enterprise", "inbound", "outbound", "referral", "upsell"]
    current_month_start = Time.current.beginning_of_month
    previous_month_start = 1.month.ago.beginning_of_month
    previous_month_end = previous_month_start.end_of_month

    12.times do |i|
      contact = contacts[i % contacts.length]
      rep = sales_reps[i % sales_reps.length]
      stage = stages[i % stages.length]
      created_at = previous_month_start + rand(0..(previous_month_end - previous_month_start).to_i)

      deal = Deal.create!(
        name: "#{Faker::Commerce.product_name} Deal",
        amount: Faker::Number.decimal(l_digits: rand(3..5), r_digits: 2),
        stage: stage,
        expected_close_date: Faker::Date.between(from: Date.current, to: 6.months.from_now),
        contact: contact,
        company: contact.company,
        user: rep,
        tenant: tenant
      )

      # Assign 1-3 random tags
      num_tags = rand(1..3)
      deal.tag_list.add(deal_tags.sample(num_tags))
      deal.save!

      deal.update_columns(created_at: created_at, updated_at: created_at, closed_at: stage == :won ? created_at + rand(1..30).days : nil)

      puts "     ✅ #{deal.name} | $#{deal.amount} | #{deal.stage} | #{rep.full_name} [#{deal.tag_list.join(', ')}]"

      # Add 1-2 notes per deal
      rand(1..2).times do
        Note.create!(
          body: Faker::Lorem.paragraph(sentence_count: rand(2..5)),
          notable: deal,
          user: all_users.sample,
          tenant: tenant
        )
      end
    end

    12.times do |i|
      contact = contacts[(i + 5) % contacts.length]
      rep = sales_reps[(i + 1) % sales_reps.length]
      stage = stages[(i + 2) % stages.length]
      created_at = current_month_start + rand(0..(Time.current - current_month_start).to_i)

      deal = Deal.create!(
        name: "#{Faker::Commerce.product_name} Deal",
        amount: Faker::Number.decimal(l_digits: rand(3..5), r_digits: 2),
        stage: stage,
        expected_close_date: Faker::Date.between(from: Date.current, to: 6.months.from_now),
        contact: contact,
        company: contact.company,
        user: rep,
        tenant: tenant
      )

      num_tags = rand(1..3)
      deal.tag_list.add(deal_tags.sample(num_tags))
      deal.save!

      deal.update_columns(created_at: created_at, updated_at: created_at, closed_at: stage == :won ? created_at + rand(1..30).days : nil)

      puts "     ✅ #{deal.name} | $#{deal.amount} | #{deal.stage} | #{rep.full_name} [#{deal.tag_list.join(', ')}]"

      rand(1..2).times do
        Note.create!(
          body: Faker::Lorem.paragraph(sentence_count: rand(2..5)),
          notable: deal,
          user: all_users.sample,
          tenant: tenant
        )
      end
    end

    # --- Notes on Contacts (1 per contact) ---
    puts "\n  📝 Creating notes on contacts..."
    contacts.each do |contact|
      Note.create!(
        body: Faker::Lorem.paragraph(sentence_count: rand(2..4)),
        notable: contact,
        user: all_users.sample,
        tenant: tenant
      )
    end
    puts "     ✅ #{contacts.length} contact notes created"
  end
end

# === Summary ===
ActsAsTenant.without_tenant do
  puts "\n" + "=" * 60
  puts "🌱 Seeding complete!"
  puts "=" * 60
  puts "   📊 Tenants:   #{Tenant.count}"
  puts "   📊 Users:     #{User.count}"
  puts "   📊 Companies: #{Company.count}"
  puts "   📊 Contacts:  #{Contact.count}"
  puts "   📊 Deals:     #{Deal.count}"
  puts "   📊 Notes:     #{Note.count}"
  puts "   📊 Tags:      #{ActsAsTaggableOn::Tag.count}"
  puts ""
  puts "   Pipeline:"
  Deal.stages.each_key do |stage|
    count = Deal.where(stage: stage).count
    total = Deal.where(stage: stage).sum(:amount)
    puts "     #{stage.ljust(15)} #{count.to_s.rjust(3)} deals  $#{total.to_f.round(2)}"
  end
  puts ""
  puts "   🔑 All test users have password: 'password123'"
  puts "   📧 Login with: admin@acme.example.com"
  puts "=" * 60
end
