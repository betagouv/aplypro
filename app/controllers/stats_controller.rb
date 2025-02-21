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
    @amounts_per_academy = Pfmp
                           .in_state(:validated)
                           .joins({ schooling: { classe: :establishment } })
                           .group("establishments.academy_code")
                           .sum(:amount)
    @schoolings_per_academy = Schooling
                              .joins(classe: :establishment)
                              .group("establishments.academy_code")
                              .count
    @schoolings_per_academy = { "01" => 30_364,
                                "02" => 68_005,
                                "03" => 28_603,
                                "04" => 74_965,
                                "06" => 30_389,
                                "07" => 33_679,
                                "08" => 74_340,
                                "09" => 115_629,
                                "10" => 72_074,
                                "11" => 64_940,
                                "12" => 56_603,
                                "13" => 41_163,
                                "14" => 81_030,
                                "15" => 39_960,
                                "16" => 65_937,
                                "17" => 90_869,
                                "18" => 55_981,
                                "19" => 32_456,
                                "20" => 51_960,
                                "22" => 15_795,
                                "23" => 39_589,
                                "24" => 102_060,
                                "25" => 108_605,
                                "27" => 5224,
                                "28" => 35_332,
                                "31" => 11_329,
                                "32" => 14_353,
                                "33" => 18_422,
                                "40" => 508,
                                "41" => 310,
                                "42" => 266,
                                "43" => 14_597,
                                "44" => 195,
                                "70" => 77_195 }
    @amounts_per_academy = { "01" => 8_182_195,
                             "02" => 17_760_710,
                             "03" => 7_453_000,
                             "04" => 21_159_275,
                             "06" => 8_270_190,
                             "07" => 9_172_010,
                             "08" => 19_829_765,
                             "09" => 28_590_700,
                             "10" => 19_192_040,
                             "11" => 17_818_590,
                             "12" => 15_073_770,
                             "13" => 10_506_095,
                             "14" => 21_728_710,
                             "15" => 9_716_290,
                             "16" => 17_673_220,
                             "17" => 24_343_820,
                             "18" => 15_491_725,
                             "19" => 8_587_015,
                             "20" => 12_952_985,
                             "22" => 3_948_640,
                             "23" => 10_327_355,
                             "24" => 28_287_885,
                             "25" => 28_182_105,
                             "27" => 1_544_630,
                             "28" => 10_092_775,
                             "31" => 2_965_100,
                             "32" => 3_800_170,
                             "33" => 4_312_560,
                             "43" => 2_716_880,
                             "44" => 51_785,
                             "70" => 20_503_580 }
  end

  def paid_pfmps_per_month
    render json: PaidPfmp.group_by_month(:paid_at, format: "%B %Y").count
  end
end
