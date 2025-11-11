# frozen_string_literal: true

require "whenever"

# NOTE: we want to try and transition as many requests every day at
# the end of the day (midnight) to allow for a little cool-down period
# for when PFMPs are being validated, and you might notice a mistake
# or want to amend something throughout the day.
every :weekday, at: "12AM" do
  runner "ConsiderPaymentRequestsJob.perform_later"
end

# NOTE: we want to send the maximum number of files (10 per day) in
# the early hours of the night. We also want them to run sequentially
# to avoid trying to grab the same requests.
#
# Do this by running at 1, 2, 3, 4 and 5AM + at every half hour. This
# leaves plenty of time for the job to succeed or fail.
5.times do |n|
  hour = n + 1

  every :weekday, at: ["#{hour}AM", "#{hour}:30AM"] do
    runner "SendPaymentRequestsJob.perform_later"
  end
end

# NOTE: we try and fetch the ASP files every weekday at 7AM because the
# average time of their automated integration/rejects emails is 4/5AM
# so this gives us a bit of margin.
every :weekday, at: "7AM" do
  runner "PollPaymentsServerJob.perform_later"
end

# NOTE: reset the attributive_decision_version for all
# Schooling records that have a version higher than 9.
#
# We want to do this every weekday at 1AM.
every :weekday, at: "12:30AM" do
  runner "JanitorJob.perform_later"
end

every :saturday, at: "8:00AM" do
  runner "GenerateReportJob.perform_later"
end
