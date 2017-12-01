# == Schema Information
#
# Table name: nobels
#
#  yr          :integer
#  subject     :string
#  winner      :string

require_relative './sqlzoo.rb'

# BONUS PROBLEM: requires sub-queries or joins. Attempt this after completing
# sections 04 and 07.

def physics_no_chemistry
  # In which years was the Physics prize awarded, but no Chemistry prize?
  execute(<<-SQL)
    SELECT
      yr
    FROM
      nobels
    WHERE
      yr NOT IN (
        SELECT
          nobels.yr
        FROM
          nobels
            JOIN nobels AS joined_nobels
              ON nobels.yr = joined_nobels.yr
          WHERE
            nobels.subject LIKE 'Physics' AND
            joined_nobels.subject LIKE 'Chemistry'
        ) AND
      subject LIKE 'Physics'
    GROUP BY
      yr
  SQL
end
