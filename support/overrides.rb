# frozen_string_literal: true

# rubocop:disable all

class Pfmp < ApplicationRecord
  def describe
    payment_info = if payment_requests.any?
                    latest = latest_payment_request
                    state = latest.current_state
                    color = case state
                           when 'paid' then "\e[32m"
                           when 'sent', 'integrated' then "\e[33m"
                           when 'rejected', 'unpaid', 'incomplete' then "\e[31m"
                           when 'ready' then "\e[36m"
                           else "\e[0m"
                           end
                    "#{color}#{state}\e[0m"
                  else
                    "\e[90mno payment request\e[0m"
                  end

    puts "PFMP ##{id}: #{start_date} → #{end_date} (#{day_count} days)"
    puts "  Amount: #{amount}€ | PFMP State: #{current_state} | Payment: #{payment_info}"
    puts "  Admin number: #{administrative_number || 'N/A'}"
    puts "  ASP Prestation ID: #{asp_prestation_dossier_id || 'N/A'}"

    if payment_requests.any?
      payment_requests.order(created_at: :desc).each do |req|
        state_color = case req.current_state
                     when 'paid' then "\e[32m"
                     when 'sent', 'integrated' then "\e[33m"
                     when 'rejected', 'unpaid', 'incomplete' then "\e[31m"
                     when 'ready' then "\e[36m"
                     else "\e[0m"
                     end
        puts "  └─ Request ##{req.id} (#{req.created_at.strftime('%Y-%m-%d')}): #{state_color}#{req.current_state}\e[0m"
        if req.in_state?(:rejected) && req.last_transition.metadata["Motif rejet"]
          puts "     Rejection reason: #{req.last_transition.metadata["Motif rejet"]}"
        end
      end
    end

    nil
  end
end

class Schooling < ApplicationRecord
  def describe
    puts "Schooling ##{id} (#{status})"
    puts "  Period: #{start_date} → #{end_date || 'ongoing'}"
    puts "  Class: #{classe.label} (#{classe.mef.code})"
    puts "  Establishment: #{classe.establishment.name} (#{classe.establishment.uai})"
    puts "  Administrative number: #{administrative_number || 'N/A'}"
    puts "  ASP dossier: #{asp_dossier_id || 'N/A'}"

    if pfmps.any?
      puts "  PFMPs (#{pfmps.count}):"
      pfmps.order(:start_date).each do |pfmp|
        puts "    - PFMP ##{pfmp.id}: #{pfmp.start_date} → #{pfmp.end_date} (#{pfmp.day_count} days)"
        puts "      Amount: #{pfmp.amount}€ | State: #{pfmp.current_state}"
      end

      total_amount = pfmps.sum(&:amount)
      paid_amount = pfmps.select(&:paid?).sum(&:amount)
      puts "  Total amount: #{total_amount}€ (Paid: #{paid_amount}€)"
    else
      puts "  No PFMPs"
    end

    nil
  end
end

class Student < ApplicationRecord
  def describe
    puts "="*80
    puts "STUDENT ##{id}: #{first_name} #{last_name} (INE: #{ine})"
    puts "="*80
    puts "Birthdate: #{birthdate}"
    puts "ASP ID: #{asp_individu_id}" if asp_individu_id.present?
    puts

    puts "SCHOOLINGS (#{schoolings.count} total):"
    puts "-"*80
    schoolings.order(start_date: :desc).each_with_index do |schooling, idx|
      puts "#{idx + 1}. #{schooling.describe}"
      puts
    end

    puts "SUMMARY:"
    puts "-"*80
    all_pfmps = pfmps.includes(:payment_requests)
    puts "Total PFMPs across all schoolings: #{all_pfmps.count}"
    puts "Total amount: #{all_pfmps.sum(&:amount)}€"
    puts "Paid amount: #{all_pfmps.select(&:paid?).sum(&:amount)}€"

    by_pfmp_state = all_pfmps.group_by(&:current_state)
    puts "\nPFMPs by state:"
    by_pfmp_state.each do |state, pfmps|
      puts "  #{state}: #{pfmps.count} (#{pfmps.sum(&:amount)}€)"
    end

    all_payment_requests = all_pfmps.flat_map(&:payment_requests)
    if all_payment_requests.any?
      puts "\nPayment requests by state:"
      all_payment_requests.group_by(&:current_state).each do |state, requests|
        color = case state
               when 'paid' then "\e[32m"
               when 'sent', 'integrated', 'ready' then "\e[33m"
               when 'rejected', 'unpaid', 'incomplete' then "\e[31m"
               else "\e[0m"
               end
        puts "  #{color}#{state}\e[0m: #{requests.count}"
      end

      puts "\nLatest payment request per PFMP:"
      all_pfmps.each do |pfmp|
        next unless pfmp.latest_payment_request
        req = pfmp.latest_payment_request
        state_color = case req.current_state
                     when 'paid' then "\e[32m"
                     when 'sent', 'integrated' then "\e[33m"
                     when 'rejected', 'unpaid', 'incomplete' then "\e[31m"
                     when 'ready' then "\e[36m"
                     else "\e[0m"
                     end
        puts "  PFMP ##{pfmp.id}: #{state_color}#{req.current_state}\e[0m (Request ##{req.id})"
      end
    end

    puts "\nVALIDATION ISSUES:"
    puts "-"*80
    all_pfmps.each do |pfmp|
      unless pfmp.valid?
        puts "PFMP ##{pfmp.id}: #{pfmp.errors.full_messages.join(', ')}"
      end
    end

    puts "="*80
    nil
  end
end
