# frozen_string_literal: true

class StatsController < ApplicationController
  before_action :infer_page_title

  skip_before_action :authenticate_user!

  def index
    @total_paid = PaidPfmp.paid.sum(:amount)
    @total_paid_students = PaidPfmp.paid.distinct.count(:student_id)
    @total_paid_pfmps = PaidPfmp.paid.count
    @validated_pfmps_per_academy = Pfmp
                                   .in_state(:validated)
                                   .joins(schooling: { classe: :establishment })
                                   .group("establishments.academy_code")
                                   .count
    @validated_pfmps_per_academy = { "01" => 28_090,
                                     "02" => 69_465,
                                     "03" => 30_502,
                                     "04" => 84_886,
                                     "06" => 33_694,
                                     "07" => 36_069,
                                     "08" => 77_249,
                                     "09" => 116_251,
                                     "10" => 74_350,
                                     "11" => 68_924,
                                     "12" => 58_670,
                                     "13" => 43_849,
                                     "14" => 93_114,
                                     "15" => 37_850,
                                     "16" => 70_142,
                                     "17" => 101_298,
                                     "18" => 61_016,
                                     "19" => 35_189,
                                     "20" => 52_861,
                                     "22" => 16_792,
                                     "23" => 39_471,
                                     "24" => 100_697,
                                     "25" => 101_490,
                                     "27" => 5952,
                                     "28" => 40_150,
                                     "31" => 11_239,
                                     "32" => 14_327,
                                     "33" => 16_709,
                                     "43" => 9772,
                                     "44" => 219,
                                     "70" => 85_919 }
  end

  def paid_pfmps_per_month
    render json: PaidPfmp.group_by_month(:paid_at, format: "%B %Y").count
  end
end
