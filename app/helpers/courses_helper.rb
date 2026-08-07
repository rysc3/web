module CoursesHelper
  # The transcript, term by term, newest first — exactly as recorded.
  # Semester credit totals are the ones printed on the record, not a sum.
  COURSE_SEMESTERS = [
    { name: "Fall 2024", credits: 22, courses: [
      { code: "CS 341L",    title: "Intro to Computer Architecture and Organization", credits: 3 },
      { code: "CS 460",     title: "Software Engineering",                            credits: 3 },
      { code: "CS 481",     title: "Computer Operating Systems",                      credits: 3 },
      { code: "CS 551",     title: "SC24 Student Cluster Competition — Grad Level",   credits: 3 },
      { code: "CS 561",     title: "Data Structures and Algorithms — Grad Level",     credits: 3 },
      { code: "GEOL 2110C", title: "Historical Geology",                              credits: 4 },
      { code: "MATH 375",   title: "Introduction to Numerical Computing",             credits: 3 }
    ] },
    { name: "Summer 2024", credits: 9, courses: [
      { code: "MATH 314",  title: "Linear Algebra with Applications (ASU)",           credits: 3 },
      { code: "STAT 345",  title: "Elements of Math Statistics and Probability",      credits: 3 },
      { code: "PHYS 1310", title: "Calculus-Based Physics 1 (ASU)",                   credits: 3 }
    ] },
    { name: "Spring 2024", credits: 20, courses: [
      { code: "CS 357L",   title: "Declarative Programming",                          credits: 3 },
      { code: "CS 361L",   title: "Data Structures and Algorithms",                   credits: 3 },
      { code: "CS 591",    title: "High Performance Computing — Grad Level",          credits: 3 },
      { code: "MATH 2531", title: "Calculus 3",                                       credits: 4 },
      { code: "MATH 306",  title: "College Geometry",                                 credits: 3 },
      { code: "MATH 356",  title: "Symbolic Logic — Grad Level",                      credits: 4 }
    ] },
    { name: "Fall 2023", credits: 20, courses: [
      { code: "CS 261",    title: "Math Foundations of Computer Science",             credits: 3 },
      { code: "CS 351L",   title: "Design of Large Programs",                         credits: 4 },
      { code: "CS 499",    title: "Individual Study — UNM EPICS Program",             credits: 3 },
      { code: "CS 499",    title: "Individual Study — SC23 Student Cluster Competition", credits: 3 },
      { code: "HNRS 1120", title: "Legacy of Ancient Greece",                         credits: 3 },
      { code: "MATH 1522", title: "Calculus 2 (CNM)",                                 credits: 4 }
    ] },
    { name: "Summer 2023", credits: 6, courses: [
      { code: "ARCH 1120", title: "Intro to Architecture",                            credits: 3 },
      { code: "ENVS 1130", title: "The Blue Planet",                                  credits: 3 }
    ] },
    { name: "Spring 2023", credits: 21, courses: [
      { code: "CS 241L",   title: "Data Organization",                                credits: 3 },
      { code: "CS 251L",   title: "Intermediate Programming",                         credits: 3 },
      { code: "CS 293",    title: "Social and Ethical Issues in Computing",           credits: 1 },
      { code: "ECE 238L",  title: "Computer Logic Design",                            credits: 4 },
      { code: "ENGL 2210", title: "Professional and Technical Communication",         credits: 3 },
      { code: "GEOL 1165", title: "People and Place",                                 credits: 3 },
      { code: "MATH 1512", title: "Calculus 1",                                       credits: 4 }
    ] },
    { name: "Fall 2022", credits: 18, courses: [
      { code: "CS 152L",    title: "Computer Programming Fundamentals",               credits: 3 },
      { code: "ENGL 1120",  title: "Composition 2",                                   credits: 3 },
      { code: "GEOL 1110",  title: "Physical Geology",                                credits: 3 },
      { code: "GEOL 1110L", title: "Physical Geology Lab",                            credits: 1 },
      { code: "GRMN 1110",  title: "German 1",                                        credits: 3 },
      { code: "MATH 1250",  title: "Trigonometry & Pre-Calculus",                     credits: 5 }
    ] }
  ].freeze

  # Printed on the record and larger than the sum of the terms below:
  # it carries transfer credit that never appears as a row.
  TOTAL_CREDITS = "144 cr".freeze

  def course_semesters
    COURSE_SEMESTERS
  end

  def course_total_credits
    TOTAL_CREDITS
  end

  def course_count
    course_semesters.sum { |s| s[:courses].size }
  end

  # "2022 — 2024", read off the oldest and newest term names.
  # Which months a term actually occupies, so the span reads as a real
  # date range rather than two bare years.
  TERM_MONTHS = {
    "Spring" => %w[Jan May],
    "Summer" => %w[Jun Jul],
    "Fall"   => %w[Aug Dec]
  }.freeze

  def course_year_span
    terms = course_semesters.filter_map do |s|
      term, year = s[:name].split
      months = TERM_MONTHS[term]
      next unless months && year

      [year.to_i, TERM_MONTHS.keys.index(term), term, year, months]
    end
    return "" if terms.empty?

    first = terms.min_by { |y, t, _, _, _| [y, t] }
    last  = terms.max_by { |y, t, _, _, _| [y, t] }

    "#{first[4].first} #{first[3]} — #{last[4].last} #{last[3]}"
  end
end
