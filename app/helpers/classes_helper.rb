# frozen_string_literal: true

module ClassesHelper
  def ribs_progress_badge(classe)
    count = classe.active_students.joins(:rib).count
    total = classe.active_students.size

    progress_badge(count, total)
  end
end
