# frozen_string_literal: true

# the helpers here aren't great (because they take shortcuts) but as
# long as they're not too smart we should be fine.
#
# PS: try and avoid adding new ones if possible.

def find_student_by_full_name(name)
  Student.all.find { |s| s.full_name == name }
end
